module JsonApiResource
  module Queryable
    extend ActiveSupport::Concern

    attr_accessor :query_result_meta
    attr_accessor :query_result_linked_data
    attr_accessor :query_result_errors

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

      QUERY_RESULT_METHOD_IDENTIFIER = "query_result_"

      # When we return a collection, these extra attributes on top of the result array from JsonApiClient are present.
      # When we find just one thing and return the first element like ActiveRecord would,
      # we lose these things.  We want them, so we will assign them to this object.
      def get_single_result(result_set)
        single_result = result_set.first

        single_result.methods.select{|method_name| is_query_result_setter_method(method_name)}.each do |setter_method_name|
          attribute_part_only = setter_method_name.to_s.gsub(QUERY_RESULT_METHOD_IDENTIFIER, "").gsub("=", "")
          if (result_set.methods.include?(attribute_part_only.to_sym))
            single_result.send(setter_method_name, result_set.send(attribute_part_only))
          end
        end

        return single_result
      end

      def is_query_result_setter_method(method_name)
        method_name.to_s.start_with?(QUERY_RESULT_METHOD_IDENTIFIER) && method_name.to_s.end_with?("=")
      end

    end
  end
end