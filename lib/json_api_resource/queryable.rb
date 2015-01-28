module JsonApiResource
  module Queryable
    extend ActiveSupport::Concern

    module ClassMethods
      def find(id)
        return nil unless id.present?
        set = (self.client_klass.find(id)).map! do |result|
          self.new(:client => result)
        end
        set.size == 1 ? set.first : set
      rescue JsonApiClient::Errors::ServerError=> e
        []
      end

      def create(attr = {})
        run_callbacks :create do
          new(:client => self.client_klass.create(attr))
        end
      end

      def where(opts = {})
        opts[:per_page] = opts.fetch(:per_page, self.per_page)
        (self.client_klass.where(opts).all).map! do |result|
          self.new(:client => result)
        end
      rescue JsonApiClient::Errors::ServerError=> e
        []
      end
    end
  end
end