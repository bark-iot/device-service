require 'securerandom'

class Device < Sequel::Model(DB)
  class Create < Trailblazer::Operation
    extend Contract::DSL

    step Model(Device, :new)
    step Contract::Build()
    step Contract::Validate()
    step :generate_token
    step :set_timestamps
    step Contract::Persist()
    step :log_success
    failure  :log_failure

    contract do
      property :house_id
      property :title
      property :com_type

      validation do
        required(:house_id).filled
        required(:title).filled
      end
    end

    def set_timestamps(options, model:, **)
      timestamp = Time.now
      model.created_at = timestamp
      model.updated_at = timestamp
    end

    def generate_token(options, model:, **)
      model.token = SecureRandom.uuid
    end

    def log_success(options, params:, model:, **)
      LOGGER.info "[#{self.class}] Created device with params #{params.to_json}. Device: #{Device::Representer.new(model).to_json}"
    end

    def log_failure(options, params:, **)
      LOGGER.info "[#{self.class}] Failed to create device with params #{params.to_json}"
    end
  end
end