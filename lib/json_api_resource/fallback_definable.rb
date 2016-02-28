module JsonApiResource
  module FallbackDefinable
    extend ActiveSupport::Concern

    included do
      class_attribute :_fallbacks
      self._fallbacks = {}

      class << self
        def falls_back_to(name, opts = {})
          self._fallbacks        = _fallbacks.dup
          
          fallback_handler_class =  opts.delete :class
          
          self._fallbacks        = _fallbacks.merge name.to_sym => fallback_handler_class.new(opts)
        end
      end
    end
  end
end