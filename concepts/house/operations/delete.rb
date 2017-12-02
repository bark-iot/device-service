class House
  class Delete < Trailblazer::Operation
    extend Contract::DSL

    step Contract::Build()
    step Contract::Validate()
    step :delete_devices
    step :log_success
    failure  :log_failure

    contract do
      property :house_id, virtual: true

      validation do
        required(:house_id).filled
      end
    end

    def delete_devices(options, params:, **)
      Device.where(house_id: params[:house_id]).delete
    end

    def log_success(options, params:, **)
      LOGGER.info "[#{self.class}] Deleted devices for house with params #{params.to_json}."
    end

    def log_failure(options, params:, **)
      LOGGER.info "[#{self.class}] Failed to delete devices for house with params #{params.to_json}"
    end
  end
end