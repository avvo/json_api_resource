module JsonApiResource
  module Requestable
    extend ActiveModel::Concern

    def request(action, options = {})
      run_callbacks action
        self.client.send(action, options).map! do |result|
          self.new(:client => result)
        end
      end
    rescue JsonApiClient::Errors::ServerError => e
      self.class.empty_set_with_errors e
    end

    module ClassMethods
      def request(action, options = {})
        run_callbacks action
          self.client_klass.send(action, options).map! do |result|
            self.new(:client => result)
          end
        end
      rescue JsonApiClient::Errors::ServerError => e
        empty_set_with_errors e
      end


      private

      def empty_set_with_errors(e)
        case e.class

        when is_a? JsonApiClient::Errors::NotFound
          error_response 404, { name: "RecordNotFound", message: e.message }

        when is_a? JsonApiClient::Errors::UnexpectedStatus
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