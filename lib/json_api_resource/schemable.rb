module JsonApiResource
  module Schemable

    extend ActiveSupport::Concern

    included do
      class_attribute :schema
      self.schema = {}
    end

    module ClassMethods
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

    def load_schema
      self.client = self.client_klass.new(self.schema)
    end

  end
end