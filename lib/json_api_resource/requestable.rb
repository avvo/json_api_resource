module JsonApiResource
  module Requestable
    extend ActiveModel::Callbacks
    extend ActiveSupport::Concern
    extend ActiveSupport::Callbacks

    included do
      def request(action, *args)
        run_callbacks action do
          self.client.send(action, *args)
        end
        self

      rescue JsonApiClient::Errors::ServerError => e
        add_error e
      end

      class << self
        def request(action, *args)
          result = self.client_class.send(action, *args)
          
          result = result.all if result.is_a? JsonApiClient::Scope
          
          result.map! do |result|
            new(client: result)
          end
          
        rescue JsonApiClient::Errors::ServerError => e
          empty_set_with_errors e
        end

        def empty_set_with_errors(e)
          append_errors e do |status, error|
            error_response status, error
          end
        end

        def append_errors(e, &block)
          case e.class.to_s

          when "JsonApiClient::Errors::NotFound"
            yield 404, { name: "RecordNotFound", message: e.message }

          when "JsonApiClient::Errors::UnexpectedStatus"
            yield e.code, { name: "UnexpectedStatus", message: e.message }

          else
            yield 500, { name: "ServerError", message: e.message }
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

      def add_error(e, &block)
        self.class.append_errors e do |status, error|
          errors.add error[:name], error[:message]
        end
      end
    end
  end
end