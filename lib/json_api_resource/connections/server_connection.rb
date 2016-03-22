module JsonApiResource
  module Connections
    class ServerConnection < Multiconnect::Connection::Base

      def initialize(options)
        super options
        @responding = true
        @timeout    = Time.now
      end

      def report_error( e )

      end

      def request( action, *args )
        if ready_for_request?
          result = self.client.send action, *args

          if result.is_a? JsonApiClient::Scope
            result = result.all
          end
          
          @responding = true

          result

        else
          raise "fall through!"
        end

      rescue JsonApiClient::Errors::NotFund => e
        empty_set_with_errors e
      rescue => e
        @responding = false
        # default circuit broken for 30 seconds. This should probably be 1 - 2 - 5 - 15 - 30 - 1 min - 2 min*
        @timeout = Time.now + 30.seconds

        # propagate the error up to be handled by Connection::Base
        raise e
      end

      def empty_set_with_errors( e )
        result = JsonApiClient::ResultSet.new

        result.meta = {status: 404}

        result.errors = ActiveModel::Errors.new(result)
        result.errors.add("RecordNotFound", e.message)

        result
      end

      private

      def ready_for_request?
        @responding || Time.now > @timeout
      end
    end
  end
end