module JsonApiResource
  module Associations
    class Base
      attr_accessor :name, :action, :key, :klass

      def initialize(associated_class, name, opts)
        self.name   = name.to_sym
        self.action = opts.fetch :action, default_action
        self.key    = opts.fetch :foreign_key do server_key(name, opts) end
        self.klass  = opts.fetch :class  do derived_class( associated_class, name ) end
      end


      def post_process( value )
        value
      end

      def server_key( association, opts )
        raise NotImplementedError
      end

      def klass( associated_class, association, opts )
        opts[:class] || derived_class( associated_class, association )
      end
      
      def type
        raise NotImplementedError
      end

      private

      def default_action
        raise NotImplementedError
      end

      def derived_class( associated_class, association )
        module_string = associated_class.to_s.split("::")[0 ... -1].join("::")
        class_string  = association.to_s.singularize.camelize
        
        # we don't necessarily want to add :: to classes, in case they have a relative path or something
        class_string = [module_string, class_string].select{|s| s.present? }.join "::"
        class_string.constantize
      end
    end
  end
end