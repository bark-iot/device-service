class House < Sequel::Model(DB)
  class List < Trailblazer::Operation
    extend Contract::DSL

    step Contract::Build()
    step Contract::Validate()
    step :list_by_user_id
    failure  :log_failure

    contract do
      property :user_id, virtual: true

      validation do
        required(:user_id).filled
      end
    end

    def list_by_user_id(options, params:, **)
      options['models'] = House.where(user_id: params[:user_id]).all
      options['models']
    end

    def log_success(options, params:, model:, **)
      LOGGER.info "[#{self.class}] Found houses for user #{params.to_json}. Houses: #{User::Representer.new(options['model']).to_json}"
    end

    def log_failure(options, params:, **)
      LOGGER.info "[#{self.class}] Failed to find user with params #{params.to_json}"
    end
  end
end