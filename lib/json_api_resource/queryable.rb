module JsonApiResource
  module Queryable
    extend ActiveSupport::Concern

    attr_accessor :meta
    attr_accessor :linked_data
    attr_accessor :errors

    define_model_callbacks :save, :create, :update_attributes

    around_create :catch_errors
    around_save   :catch_errors
    around_update_attributes :catch_errors

    module ClassMethods

      include JsonApiResource::Conversions

      def find(id)
        return nil unless id.present?

        results = request(:find, id: id)
        JsonApiResource::Handlers::FindHandler.new(results).results # <= <#JsonApiclient::ResultSet @errors => <...>, @data => <...>, @linked_data => <...>>
      end

      def create(opts = {})
        request(:create, opts)
      end

      def where(opts = {})
        opts[:per_page] = opts.fetch(:per_page, self.per_page)
        request(:where, opts).result_set
      end
    end

    module InstanceMethods
      def save
        request :save
      end

      def count
        request :count
      end

      def update_attributes(attrs = {})
        request :update_attributes, attrs
      end

      def catch_errors
        yield

        self.errors ||= ActiveModel::Errors.new(self)
        ApiErrors(self.client.errors).each do | k,messages|
          self.errors.add(k.to_sym, Array(messages).join(', '))
        end
        self.errors
      end    
    end
  end
end
