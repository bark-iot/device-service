require 'securerandom'

class House < Sequel::Model(DB)
  class Delete < Trailblazer::Operation
    extend Contract::DSL

    step Contract::Build()
    step Contract::Validate()
    step :delete
    step :log_success
    failure  :log_failure

    contract do
      property :id, virtual: true
      property :user_id, virtual: true

      validation do
        required(:id).filled
        required(:user_id).filled
      end
    end

    def delete(options, params:, **)
      options['model'] = House.where(id: params[:id]).where(user_id: params[:user_id]).first
      return false unless options['model']
      options['model'].destroy
    end

    step :log_success
    failure  :log_failure


    def log_success(options, params:, **)
      LOGGER.info "[#{self.class}] Deleted house with params #{params.to_json}."
    end

    def log_failure(options, params:, **)
      LOGGER.info "[#{self.class}] Failed to delete house with params #{params.to_json}"
    end
  end
end