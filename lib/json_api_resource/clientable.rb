require 'multiconnect'

module JsonApiResource
  module Clientable
    extend ActiveSupport::Concern

    included do
      class_attribute :client_class
      self.client_class = nil
      include Multiconnect::Connectable

      class << self
        def wraps(client)
          self.client_class = client

          # now that we know where to connect to, let's do it
          add_connection Connections::ServerConnection, client: client
        end
      end
    end
  end
end