module JsonApiResource
  module Connections
    class ServerConnection < Multiconnect::Connection::Base
      include Keyable

      class_attribute :error_notifier

      def report_error( e )
        unless i.is_a? ServerNotReadyError
          error_notifier.notify( self, e ) if error_notifier.present?
        end
      end

      def request( action, *args )
        client_request(action, *args)

      rescue JsonApiClient::Errors::NotFound => e
        empty_set_with_errors e
      end

      def empty_set_with_errors( e )
        result = JsonApiClient::ResultSet.new

        result.meta = {status: 404}

        result.errors = ActiveModel::Errors.new(result)
        result.errors.add("RecordNotFound", e.message)

        result
      end

      private

      def client_request(action, *args)
        result = self.client.send action, *args

        if result.is_a? JsonApiClient::Scope
          result = result.all
        end

        result
      end
    end
  end
end