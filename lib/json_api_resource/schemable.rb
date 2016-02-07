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
    end
  end
end