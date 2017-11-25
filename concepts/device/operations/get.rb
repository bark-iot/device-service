require 'securerandom'

class Device < Sequel::Model(DB)
  class Get < Trailblazer::Operation
    extend Contract::DSL

    step :model!
    step Contract::Build()
    step Contract::Validate()
    step :log_success
    failure  :log_failure

    contract do
      property :house_id, virtual: true
      property :id, virtual: true

      validation do
        required(:house_id).filled
        required(:id).filled
      end
    end

    def model!(options, params:, **)
      options['model'] = Device.where(house_id: params[:house_id]).where(id: params[:id]).first
      options['model']
    end

    def log_success(options, params:, model:, **)
      LOGGER.info "[#{self.class}] Found device with params #{params.to_json}. Device: #{Device::Representer.new(model).to_json}"
    end

    def log_failure(options, params:, **)
      LOGGER.info "[#{self.class}] Failed to find device with params #{params.to_json}"
    end
  end
end