module JsonApiResource
  module Clientable
    extend ActiveSupport::Concern

    included do
      class_attribute :client_class
      self.client_class = nil

      class << self
        def wraps(client)
          self.client_class = client
        end
      end
    end
  end
end