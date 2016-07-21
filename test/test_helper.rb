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


module Account
  module Client
    class Base < JsonApiClient::Resource
      self.site = "http://localhost:3000/api/1"
    end

    class User < Base
      class_attribute :attribute_count
      self.attribute_count = 0

      def no_name
        "no_name"
      end

      collection_endpoint :search, request_method: :get
    end

    class Attribute < Base
    end

    class PartnerUser < Base
    end

    class Image < Base
    end

    class Address < Base
    end

    class Friendship < Base
    end

    class Permission < Base
    end

    class Thing < Base
    end
  end

  module V1
    class PartnerUser < JsonApiResource::Resource
      wraps Account::Client::PartnerUser
    end

    class Friendship < JsonApiResource::Resource
      wraps Account::Client::Friendship
    end

    class Image < JsonApiResource::Resource
      wraps Account::Client::Image
    end

    class Address < JsonApiResource::Resource
      wraps Account::Client::Address
    end

    class Permission < JsonApiResource::Resource
      wraps Account::Client::Permission
    end

    class Thing < JsonApiResource::Resource
      wraps Account::Client::Thing
    end

    class Attribute < JsonApiResource::Resource
      wraps Account::Client::Attribute

      properties  id: nil,
                  user_id: nil,
                  name: "",
                  value: "",
                  updated_at: nil

      belongs_to :user
    end

    class User < JsonApiResource::Resource
      wraps Account::Client::User

      properties  id: nil, 
                  name: "",
                  associated_website_user_id: nil,
                  permission_ids: [],
                  updated_at: nil

      belongs_to :associated_website_user, class: Account::V1::PartnerUser

      has_one    :address
      has_one    :profile_image, class: Account::V1::Image, type: :profile
      has_one    :thing, foreign_key: :person_id

      has_many   :friendships
      has_many   :attrs, class: Account::V1::Attribute

      has_many   :permissions, prefetched_ids: :permission_ids
    end
  end
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