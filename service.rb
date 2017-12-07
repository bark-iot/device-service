require 'sinatra'
require 'sinatra/namespace'
require 'sinatra/reloader' if development?
require './config/logging.rb'
require './config/authorize.rb'
require './config/database.rb'
require './config/concepts.rb'
require './config/redis.rb'

set :bind, '0.0.0.0'
set :port, 80
set :public_folder, 'public'

get '/devices/docs' do
  redirect '/devices/docs/index.html'
end

namespace '/houses/:house_id' do
  get '/devices' do
    result = Device::List.(house_id: params[:house_id])
    if result.success?
      body Device::Representer.for_collection.new(result['models']).to_json
    else
      status 422
      body result['contract.default'].errors.messages.uniq.to_json
    end
  end

  post '/devices' do
    result = Device::Create.(params)
    if result.success?
      body Device::Representer.new(result['model']).to_json
    else
      if result['contract.default']
        status 422
        body result['contract.default'].errors.messages.uniq.to_json
      else
        status 404
      end
    end
  end

  get '/devices/:id' do
    result = Device::Get.(params)
    if result.success?
      body Device::Representer.new(result['model']).to_json
    else
      if result['contract.default']
        status 422
        body result['contract.default'].errors.messages.uniq.to_json
      else
        status 404
      end
    end
  end

  put '/devices/:id' do
    result = Device::Update.(params)
    if result.success?
      body Device::Representer.new(result['model']).to_json
    else
      if result['contract.default']
        status 422
        body result['contract.default'].errors.messages.uniq.to_json
      else
        status 404
      end
    end
  end

  post '/devices/:id/approved' do
    result = Device::Approve.(params)
    if result.success?
      body Device::Representer.new(result['model']).to_json
    else
      if result['contract.default']
        status 422
        body result['contract.default'].errors.messages.uniq.to_json
      else
        status 404
      end
    end
  end

  delete '/devices/:id' do
    result = Device::Delete.(params)
    if result.success?
      status 200
    else
      if result['contract.default'].errors.messages.size > 0
        status 422
        body result['contract.default'].errors.messages.uniq.to_json
      else
        status 404
      end
    end
  end
end