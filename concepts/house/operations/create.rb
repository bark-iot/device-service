require 'securerandom'

class House < Sequel::Model(DB)
  class Create < Trailblazer::Operation
    extend Contract::DSL

    step Model(House, :new)
    step Contract::Build()
    step Contract::Validate()
    step :generate_key_and_secret
    step :set_timestamps
    step Contract::Persist()
    step :log_success
    failure  :log_failure

    contract do
      property :user_id
      property :title
      property :address

      validation do
        required(:user_id).filled
        required(:title).filled
      end
    end

    def set_timestamps(options, model:, **)
      timestamp = Time.now
      model.created_at = timestamp
      model.updated_at = timestamp
    end

    def generate_key_and_secret(options, model:, **)
      model.key = SecureRandom.uuid
      model.secret = SecureRandom.hex(32)
    end


    def log_success(options, params:, model:, **)
      LOGGER.info "[#{self.class}] Created house with params #{params.to_json}. House: #{House::Representer.new(model).to_json}"
    end

    def log_failure(options, params:, **)
      LOGGER.info "[#{self.class}] Failed to create house with params #{params.to_json}"
    end
  end
end