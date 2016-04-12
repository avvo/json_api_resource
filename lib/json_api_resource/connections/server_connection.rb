module JsonApiResource
  module Connections
    class ServerConnection < Multiconnect::Connection::Base
      class_attribute :error_notifier

      def report_error( e )
        error_notifier.notify( self, e ) if error_notifier.present?
      end

      def request( action, *args )

        result = self.client.send action, *args

        if result.is_a? JsonApiClient::Scope
          result = result.all
        end

        result

      rescue JsonApiClient::Errors::NotFound => e

        result = JsonApiClient::ResultSet.new

        result.meta = {status: 404}

        result.errors = ActiveModel::Errors.new(result)
        result.errors.add("RecordNotFound", e.message)

        result

      end
    end
  end
end