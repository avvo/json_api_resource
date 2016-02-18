module JsonApiResource
  module Cacheable
    extend ActiveSupport::Concern
    def cache_key
      @cache_key ||= Digest::SHA256.hexdigest(self.attributes.to_s)
    end
  end
end