require 'multiconnect'

module JsonApiResource
  module Cacheable
    extend ActiveSupport::Concern
    
    included do
      def cache_key
        @cache_key ||= Digest::SHA256.hexdigest(self.to_json)
      end
    end
  end
end
