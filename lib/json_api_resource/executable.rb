require 'multiconnect'

module JsonApiResource
  module Executable
    extend ActiveModel::Callbacks
    extend ActiveSupport::Concern
    extend ActiveSupport::Callbacks

    included do

      include Multiconnect::Connectable

      def execute(action, *args)
        result = nil
        run_callbacks action do
          result = connection.execute( action, *args )
        end
        result.success?
      end

      class << self
        def execute(action, *args)
          result = request(action, *args)
          
          result.map! do |result|
            new(client: result)
          end
        rescue Multiconnect::Error::UnsuccessfulRequest => e
          
          empty_500_set
          
        end

        def empty_500_set
          result = JsonApiClient::ResultSet.new
          result.meta = {status: 500}

          result.errors = ActiveModel::Errors.new(result)
          result.errors.add("ServerError", "Unable to connect to server or server returned 500")

          result
        end
      end

      private 

      def connection
        @connection ||= Connections::ServerConnection.new( client: self.client )
      end
    end
  end
end