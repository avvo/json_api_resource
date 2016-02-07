Bundler.require(:default, :test)

require 'simplecov'
SimpleCov.start

require 'minitest/autorun'
require 'webmock/minitest'
require 'pp'
require 'json_api_resource'
require 'json_api_client'

class UserClient < JsonApiClient::Resource
  self.site = "http://localhost:3000/api/1"
end

class AttributeClient < JsonApiClient::Resource
  self.site = "http://localhost:3000/api/1"
end

# old model. Let's keep some backwards compat? maybe?
class UserResource < JsonApiResource::Resource
  class << self
    def client_class
      UserClient
    end

    def schema
      { id: 0,
        name: ""
      }
    end
  end
end

class PropUserResource < JsonApiResource::Resource
  wraps UserClient

  property :id, 0
  property :name, ""
  property :updated_at, nil
end

class PropsUserResource < JsonApiResource::Resource
  wraps UserClient

  properties  id: 0,
              name: "",
              updated_at: nil
end

class PropPropsUserResource < JsonApiResource::Resource
  wraps UserClient

  properties  id: 0,
              name: ""
  property :updated_at
end