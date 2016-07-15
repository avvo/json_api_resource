module JsonApiResource
  module Errors
    extend ActiveSupport::Concern
    included do

      def raise_if( condition, message, error = JsonApiResource::Errors::InvalidAssociation )
        self.class.raise_if condition, message, error
      end

      def raise_unless( condition, message, error = JsonApiResource::Errors::InvalidAssociation )
        raise_if !condition, message, error
      end


      class << self

        def raise_if( condition, message, error = JsonApiResource::Errors::InvalidAssociation )
          raise error.new(class: self, message: message ) if condition
        end

        def raise_unless( condition, message, error = JsonApiResource::Errors::InvalidAssociation )
          raise_if !condition, message, error
        end
      end
    end

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