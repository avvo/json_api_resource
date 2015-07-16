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
        error_result e
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
        error_result e
      end

      private

      # When we return a collection, these extra attributes on top of the result array from JsonApiClient are present.
      # When we find just one thing and return the first element like ActiveRecord would,
      # we lose these things.  We want them, so we will assign them to this object.
      def single_result(results)
        result = results.first

        query_methods_for(result).each do |setter|
          getter = setter.to_s.gsub("=", "")
          puts getter, results.respond_to?(getter), results.methods.respond_to?(getter), results.inspect
          if results.respond_to? getter

            results_meta = results.send getter
            
            result.send setter, results_meta
          end
        end

        return result
      end

      def query_methods_for(result)
        [:meta=, :linked_data=, :errors=].select do |setter|
          result.respond_to?(setter)
        end
      end

      def error_result(e)
        result = JsonApiClient::ResultSet.new
        case e.class 
   
        when JsonApiClient::Errors::NotFound
          result.meta = {status: 404, errors: "RecordNotFound"}
   
        when JsonApiClient::Errors::UnexpectedStatus
          result.meta = {status: e.code, errors: "UnexpectedStatus"}
        
        else
          result.meta = {status: 500, errors: "ServerError"}
        end

        result
      end
    end
  end
end