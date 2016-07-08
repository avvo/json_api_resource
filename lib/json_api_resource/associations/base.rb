module JsonApiResource
  module Associations
    class Base
      attr_accessor :name, :action, :key, :opts

      def initialize(associated_class, name, opts = {})
        self.name   = name.to_sym
        self.root   = associated_class
        
        self.action = opts.delete :action       do default_action end
        self.key    = opts.delete :foreign_key  do server_key end
        self.opts   = opts
        validate_options
      end

      def type
        raise NotImplementedError
      end

      def query
        raise NotImplementedError
      end

      # klass has to be lazy initted for circular dependencies
      def klass
        @klass ||= opts.delete :class do derived_class end
      end

      def post_process( value )
        value
      end

      protected

      attr_accessor :root

      def server_key
        raise NotImplementedError
      end
      
      def default_action
        raise NotImplementedError
      end

      def derived_class
        module_string = root.to_s.split("::")[0 ... -1].join("::")
        class_string  = name.to_s.singularize.camelize
        
        # we don't necessarily want to add :: to classes, in case they have a relative path or something
        class_string = [module_string, class_string].select{|s| s.present? }.join "::"
        class_string.constantize
      end

      RESERVED_KEYWORDS = [:attributes, :_associations, :_cached_associations, :schema, :client]

      def validate_options
        raise_unless action.present?, "Invalid action: #{root}.#{name}"
        raise_unless    key.present?, "Invalid foreign_key for #{root}.#{name}"

        raise_if RESERVED_KEYWORDS.include?(name), "'#{name}' is a reserved keyword for #{root}"
      end

      def raise_if condition, message
        raise JsonApiResource::Errors::InvalidAssociation.new(class: root, message: message ) if condition
      end

      def raise_unless condition, message
        raise_if !condition, message
      end
    end
  end
end