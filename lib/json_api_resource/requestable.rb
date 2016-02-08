module JsonApiResource
  module Requestable
    extend ActiveSupport::Concern

    included do
      def request(action, options = {})
        # run_callbacks action
          self.client.send(action, options).map! do |result|
            new(client: result)
          end
        # end
        self

      rescue JsonApiClient::Errors::ServerError => e
        self.class.empty_set_with_errors e
      end

      class << self
        def request(action, options = {})
          self.client_class.send(action, options).map! do |result|
            new(client: result).save
          end
        rescue JsonApiClient::Errors::ServerError => e
          empty_set_with_errors e
        end


        private

        def empty_set_with_errors(e)
          case e.class.to_s

          when "JsonApiClient::Errors::NotFound"
            error_response 404, { name: "RecordNotFound", message: e.message }

          when "JsonApiClient::Errors::UnexpectedStatus"
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
end