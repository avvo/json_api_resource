module JsonApiResource
  module Fallbackable
    extend ActiveSupport::Concern
    include JsonApiResource::Conversions

    included do 
      attr_accessor :_active_fallback

      def using_fallback?(fallback_type = nil)
        Boolean(_active_fallback && fallback_type == _active_fallback)
      end
    end
  end
end