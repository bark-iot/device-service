class Device < Sequel::Model(DB)
  class List < Trailblazer::Operation
    extend Contract::DSL

    step Contract::Build()
    step Contract::Validate()
    step :list_by_house_id
    failure  :log_failure

    contract do
      property :house_id, virtual: true

      validation do
        required(:house_id).filled
      end
    end

    def list_by_house_id(options, params:, **)
      options['models'] = Device.where(house_id: params[:house_id]).all
      options['models']
    end

    def log_success(options, params:, model:, **)
      LOGGER.info "[#{self.class}] Found devices for house #{params.to_json}. Devices: #{Device::Representer.for_collection.new(result['models']).to_json}"
    end

    def log_failure(options, params:, **)
      LOGGER.info "[#{self.class}] Failed to find devices with params #{params.to_json}"
    end
  end
end