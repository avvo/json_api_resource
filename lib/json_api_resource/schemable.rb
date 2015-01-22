module JsonApiResource
  module Schemable

    extend ActiveSupport::Concern

    included do
      class_attribute :schema
      self.schema = {}
    end

    module ClassMethods
      def property(opts = {})
        opts.each do |attr_name,default|
          self.schema[attr_name.to_sym] = default || nil
        end
      end
    end

    protected

    def load_schema
      self.client = self.client_klass.new(self.schema)
    end

  end
end