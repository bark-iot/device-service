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
      property :approved
      property :online
  end
end