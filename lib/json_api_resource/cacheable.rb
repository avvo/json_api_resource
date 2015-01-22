module JsonApiResource
  module Cacheable
    extend ActiveSupport::Concern
    def cache_key
      case
        when new_record?
          "#{self.class.model_name.cache_key}/new"
        when timestamp = self[:updated_at]
          "#{self.class.model_name.cache_key}/#{id}-#{timestamp}"
        else
          "#{self.class.model_name.cache_key}/#{id}"
      end
    end
  end
end