module JsonApiResource
  module Queryable
    extend ActiveSupport::Concern

    attr_accessor :meta
    attr_accessor :linked_data
    attr_accessor :errors

    module ClassMethods

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

      private

      # When we return a collection, these extra attributes on top of the result array from JsonApiClient are present.
      # When we find just one thing and return the first element like ActiveRecord would,
      # we lose these things.  We want them, so we will assign them to this object.
      def single_result(results)
        result = results.first

        result.meta = results.meta

        results.errors.each do |error|
          result.errors.add error
        end

        result.linked_data = results.linked_data if results.respond_to? :linked_data

        return result
      end

      def pretty_error(e)
        case e.class 
   
        when JsonApiClient::Errors::NotFound
          error_response 404, { name: "RecordNotFound", message: e.message }
   
        when JsonApiClient::Errors::UnexpectedStatus
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