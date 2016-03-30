module JsonApiResource
  module Connections
    class CacheConnection < Multiconnect::Connection::Base
      include Keyable
      
      class << self
        attr_accessor :cache
      end

      def report_error( e )
      end

      def request( action, *args )
        key = cache_key(client, action, args)
        self.class.cache.fetch key
      end
    end
  end
end