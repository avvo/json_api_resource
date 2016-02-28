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
          
          JsonApiResource::ResultSet.build( result.map! do |result|
                       new(client: result)
                     end )
          
        rescue JsonApiClient::Errors::ServerError => e
          server_error_response e, action, *args
        end

        def server_error_response(e, action, *args)
          response = append_errors e do |status, error|
            error_response status, error
          end

          _fallbacks.each do |fallback|
            # only try to populate data if the set is blank
            unless response.using_fallback?
              # try to populate the data for the current action
              response << fallback.data_for(action, *args)
              # set fallback actuve flag to prevent lower-level fallbacks from adding data
              response._active_fallback = fallback unless response.empty?
            end
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
          result = JsonApiResource::ResultSet.new

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