module JsonApiResource
  module Schemable

    extend ActiveSupport::Concern

    included do
      class_attribute :schema
      self.schema = {}
      
      class << self
        def properties(opts = {})
          self.schema = schema.dup
          opts.each_pair do |name, default|
            property name, default
          end
        end

        def property(name, default = nil)
          self.schema = schema.merge name.to_sym => default
        end
      end

      protected

      def populate_missing_fields
        self.class.schema.each_pair do |key, value|
          unless self.attributes.has_key?(key)
            self.attributes[key] = value
          end
        end
      end
    end
  end
end