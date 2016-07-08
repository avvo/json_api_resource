module JsonApiResource
  module Errors
    class JsonApiResourceError < StandardError
      def initialize(opts = {})
        @klass    = opts.fetch :class, JsonApiResource::Resource
        @message  = opts.fetch :message, ""
      end

      def message
        "#{@klass}: #{@message}"
      end
    end

    class UnsuccessfulRequest < JsonApiResourceError
    end

    class InvalidAssociation < JsonApiResourceError
    end
  end
end