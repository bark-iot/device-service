require 'roar/decorator'
require 'roar/json'

class Device < Sequel::Model(DB)
  class Representer < Roar::Decorator
      include Roar::JSON

      property :id
      property :house_id
      property :title
      property :token
      property :com_type
      property :approved_at
      property :online
      property :created_at
      property :updated_at
  end
end