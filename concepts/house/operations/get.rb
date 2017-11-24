require 'securerandom'

class House < Sequel::Model(DB)
  class Get < Trailblazer::Operation
    extend Contract::DSL

    step :model!
    step Contract::Build()
    step Contract::Validate()
    step :log_success
    failure  :log_failure

    contract do
      property :user_id, virtual: true
      property :id, virtual: true

      validation do
        required(:user_id).filled
        required(:id).filled
      end
    end

    def model!(options, params:, **)
      options['model'] = House.where(user_id: params[:user_id]).where(id: params[:id]).first
      options['model']
    end

    def log_success(options, params:, model:, **)
      LOGGER.info "[#{self.class}] Found house with params #{params.to_json}. House: #{House::Representer.new(model).to_json}"
    end

    def log_failure(options, params:, **)
      LOGGER.info "[#{self.class}] Failed to find house with params #{params.to_json}"
    end
  end
end