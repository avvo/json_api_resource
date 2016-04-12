module JsonApiResource
  module Queryable
    extend ActiveSupport::Concern

    included do

      define_model_callbacks :save, :update_attributes

      around_save   :update_meta
      around_update_attributes :update_meta

      class << self

        MAX_PAGES_FOR_ALL = 25

        def find(id)
          return nil unless id.present?

          results = execute(:find, id: id)
          JsonApiResource::Handlers::FindHandler.new(results).result # <= <#JsonApiclient::ResultSet @errors => <...>, @data => <...>, @linked_data => <...>>
        end

        def where(opts = {})
          opts[:per_page] = opts.fetch(:per_page, self.per_page)
          execute(:where, opts)
        end
      end

      
      def save
        execute :save
      end

      def update_attributes(attrs = {})
        execute :update_attributes, attrs
      end

      def update_meta
        yield

        self.errors ||= ActiveModel::Errors.new(self)
        ApiErrors(self.client.errors).each do | k,messages|
          self.errors.add(k.to_sym, Array(messages).join(', '))
        end
        self.errors

        self.meta = self.client.last_request_meta
      end
    end
  end
end
