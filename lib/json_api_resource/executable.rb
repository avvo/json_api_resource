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
          result = Connections::ServerConnection.new( client: self.client ).execute( action, *args )
        end
        result.success?
      end

      class << self
        def execute(action, *args)
          result = request(action, *args)
          
          result.map! do |result|
            new(client: result)
          end
        rescue Multiconnect::Error::UnsuccessfulRequestError => e
          Multiconnect::Connection::Result.new
        end
      end
    end
  end
end