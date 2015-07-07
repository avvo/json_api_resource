module JsonApiResource
  module Queryable
    extend ActiveSupport::Concern

    attr_accessor :meta
    attr_accessor :linked_data
    attr_accessor :errors

    module ClassMethods

      def find(id)
        return nil unless id.present?
        set = (self.client_klass.find(id)).map! do |result|
          self.new(:client => result)
        end
        set.size == 1 ? get_single_result(set) : set
      rescue JsonApiClient::Errors::ServerError => e
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

      private

      QUERY_RESULT_METADATA_SETTERS = [:meta=, :linked_data=, :errors=]

      # When we return a collection, these extra attributes on top of the result array from JsonApiClient are present.
      # When we find just one thing and return the first element like ActiveRecord would,
      # we lose these things.  We want them, so we will assign them to this object.
      def get_single_result(result_set)
        single_result = result_set.first

        query_methods(single_result).each do |setter|
          getter = setter.to_s.gsub("=", "")
          if (result_set.methods.respond_to?(getter.to_sym))
            single_result.send(setter, result_set.send(getter))
          end
        end

        return single_result
      end

      def query_methods(single_obj)
        methods = []
        QUERY_RESULT_METADATA_SETTERS.each do |setter|
          methods << setter if single_obj.respond_to?(setter)
        end
        methods
      end

    end
  end
end