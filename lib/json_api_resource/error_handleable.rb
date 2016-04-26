module JsonApiResource
  module ErrorHandleable
    extend ActiveSupport::Concern

    included do
      class << self

        def handle_failed_request( e )
          raise JsonApiResource::Errors::UnsuccessfulRequest.new(class: self, message: e.message)
        end
      end
    end
  end
end