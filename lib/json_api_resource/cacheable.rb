require 'multiconnect'

module JsonApiResource
  module Cacheable
    extend ActiveSupport::Concern
    
    included do
      def cache_key
        @cache_key ||= Digest::SHA256.hexdigest(self.to_json)
      end

      include Multiconnect::Connectable

      class << self
        class_attribute :_fallbacks
        self._fallbacks = []

        def fallback_to_cache_on(actions)
          self._fallbacks = _fallbacks + Array(actions)
          add_connection Connections::CacheFallbackConnection client: self.client_class, only: self._fallbacks
        end
      end
    end
  end
end