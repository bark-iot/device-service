require 'securerandom'

class Device < Sequel::Model(DB)
  class Update < Trailblazer::Operation
    extend Contract::DSL

    step :model!
    step Contract::Build()
    step Contract::Validate()
    step :set_timestamps
    step Contract::Persist()
    step :log_success
    failure  :log_failure

    contract do
      property :house_id
      property :title
      property :com_type
      property :id

      validation do
        required(:house_id).filled
        required(:title).filled
        required(:id).filled
      end
    end

    def model!(options, params:, **)
      options['model'] = Device.where(house_id: params[:house_id]).where(id: params[:id]).first
      options['model']
    end

    def set_timestamps(options, model:, **)
      timestamp = Time.now
      model.updated_at = timestamp
    end

    def log_success(options, params:, model:, **)
      LOGGER.info "[#{self.class}] Updated device with params #{params.to_json}. Device: #{Device::Representer.new(model).to_json}"
    end

    def log_failure(options, params:, **)
      LOGGER.info "[#{self.class}] Failed to update device with params #{params.to_json}"
    end
  end
end