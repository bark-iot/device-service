require 'securerandom'

class House < Sequel::Model(DB)
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
      property :user_id
      property :title
      property :address
      property :id

      validation do
        required(:user_id).filled
        required(:title).filled
        required(:id).filled
      end
    end

    def model!(options, params:, **)
      options['model'] = House.where(user_id: params[:user_id]).where(id: params[:id]).first
      options['model']
    end

    def set_timestamps(options, model:, **)
      timestamp = Time.now
      model.updated_at = timestamp
    end

    def log_success(options, params:, model:, **)
      LOGGER.info "[#{self.class}] Updated house with params #{params.to_json}. House: #{House::Representer.new(model).to_json}"
    end

    def log_failure(options, params:, **)
      LOGGER.info "[#{self.class}] Failed to update house with params #{params.to_json}"
    end
  end
end