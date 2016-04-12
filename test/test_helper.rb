Bundler.require(:default, :test)

require 'simplecov'
SimpleCov.start

require 'minitest/autorun'
require 'webmock/minitest'
require 'pp'
require 'json_api_resource'
require 'json_api_client'

class User < JsonApiClient::Resource
  class_attribute :attribute_count
  self.attribute_count = 0

  self.site = "http://localhost:3000/api/1"

  def no_name
    "no_name"
  end

  collection_endpoint :search, request_method: :get
end

class Attribute < JsonApiClient::Resource
  self.site = "http://localhost:3000/api/1"
end

class UserResource < JsonApiResource::Resource
  wraps User
  
  properties id: nil,
           name: ""

end

class PropUserResource < JsonApiResource::Resource
  wraps User

  property :id
  property :name, ""
  property :updated_at, nil
end

class PropsUserResource < JsonApiResource::Resource
  wraps User

  properties  id: nil,
              name: "",
              updated_at: nil
end

class PropPropsUserResource < JsonApiResource::Resource
  wraps User

  properties  id: nil,
              name: ""
  property :updated_at
end

def raise_client_error!
  -> (*args){ raise JsonApiClient::Errors::ServerError.new("http://localhost:3000/api/1") }
end

def raise_404!
  -> (*args){ raise JsonApiClient::Errors::NotFound.new("http://localhost:3000/api/1") }
end

class Notifier < JsonApiResource::ErrorNotifier::Base
  class << self
    def notify( connection, error )
      $error = [connection.class, error.class]
    end
  end 
end

JsonApiResource::Connections::ServerConnection.error_notifier = Notifier