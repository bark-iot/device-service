require 'securerandom'

class Device < Sequel::Model(DB)
  class Approve < Trailblazer::Operation
    extend Contract::DSL

    step :model!
    step Contract::Build()
    step Contract::Validate()
    step :set_approved
    step :set_timestamps
    step :persist
    step :log_success
    failure :log_failure

    contract do
      property :house_id
      property :approved, virtual: true
      property :id

      validation do
        required(:house_id).filled
        required(:approved).filled
        required(:id).filled
      end
    end

    def model!(options, params:, **)
      options['model'] = Device.where(house_id: params[:house_id]).where(id: params[:id]).first
      options['model']
    end

    def set_approved(options, params:, model:, **)
      if params[:approved] == 'true'
        timestamp = Time.now
        model.approved_at = timestamp
      else
        model.approved_at = nil
      end
      true
    end

    def persist(options, params:, model:, **)
      options['model'].save
    end

    def set_timestamps(options, model:, **)
      timestamp = Time.now
      model.updated_at = timestamp
    end

    def log_success(options, params:, model:, **)
      LOGGER.info "[#{self.class}] Approved device with params #{params.to_json}. Device: #{Device::Representer.new(model).to_json}"
    end

    def log_failure(options, params:, **)
      LOGGER.info "[#{self.class}] Failed to approve device with params #{params.to_json}"
    end
  end
end