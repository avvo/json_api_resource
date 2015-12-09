module JsonApiResource
  module Queryable
    extend ActiveSupport::Concern

    attr_accessor :meta
    attr_accessor :linked_data
    attr_accessor :errors

    MAX_PAGES_FOR_ALL = 25

    module ClassMethods

      include JsonApiResource::Conversions

      def find(id)
        return nil unless id.present?
        results = self.client_klass.find(id).map! do |result|
          self.new(:client => result)
        end
        results.size == 1 ? single_result(results) : results
      rescue JsonApiClient::Errors::ServerError => e
        pretty_error e
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
      rescue JsonApiClient::Errors::ServerError => e
        pretty_error e
      end

      def all_without_pagination(opts = {})
        page_total = 1
        current_page = 1
        all_results = []
        until (current_page > page_total) || (current_page > MAX_PAGES_FOR_ALL)
          page_of_results = where({:page => current_page}.merge(opts))
          all_results << page_of_results
          page_total = page_of_results.meta[:total_pages]
          current_page = current_page + 1
        end
        all_results.flatten.compact
      end

      private

      # When we return a collection, these extra attributes on top of the result array from JsonApiClient are present.
      # When we find just one thing and return the first element like ActiveRecord would,
      # we lose these things.  We want them, so we will assign them to this object.
      def single_result(results)
        result = results.first

        result.meta = results.meta

        result.linked_data = results.linked_data if results.respond_to? :linked_data

        return result
      end

      def pretty_error(e)
        case e.class.to_s

        when 'JsonApiClient::Errors::NotFound'
          error_response 404, { name: "RecordNotFound", message: e.message }

        when 'JsonApiClient::Errors::UnexpectedStatus'
          error_response e.code, { name: "UnexpectedStatus", message: e.message }

        else
          error_response 500, { name: "ServerError", message: e.message }
        end
      end

      def error_response(status, error)
        result = JsonApiClient::ResultSet.new

        result.meta = {status: status}

        result.errors = ActiveModel::Errors.new(result)
        result.errors.add(error[:name], Array(error[:message]).join(', '))

        result
      end
    end
  end
end