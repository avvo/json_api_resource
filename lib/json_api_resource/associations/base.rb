module JsonApiResource
  module Associations
    class Base
      include ::JsonApiResource::Errors
      attr_accessor :name, :action, :key, :opts, :root

      def initialize(associated_class, name, opts = {})
        self.name   = name.to_sym
        self.root   = associated_class
        self.opts   = opts.merge( ignore_pagination: true )
        
        self.action = opts.delete :action       do default_action end
        self.key    = opts.delete :foreign_key  do server_key end

        self.key    = self.key.try :to_sym
        validate_options
      end

      def type
        raise NotImplementedError
      end

      def query( root_insatnce )
        raise NotImplementedError
      end

      def callable?( root_insatnce )
        raise NotImplementedError
      end

      def default_nil
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

      def server_key
        raise NotImplementedError
      end
      
      def default_action
        raise NotImplementedError
      end

      def derived_class
        module_string = self.root.to_s.split("::")[0 ... -1].join("::")
        class_string  = name.to_s.singularize.camelize
        
        # we don't necessarily want to add :: to classes, in case they have a relative path or something
        class_string = [module_string, class_string].select{|s| s.present? }.join "::"
        class_string.constantize
      end

      RESERVED_KEYWORDS = [:attributes, :_associations, :_cached_associations, :schema, :client]

      def validate_options
        raise_unless action.present?, "Invalid action: #{self.root}.#{name}"
        raise_unless    key.present?, "Invalid foreign_key for #{self.root}.#{name}"

        raise_if RESERVED_KEYWORDS.include?(name), "'#{name}' is a reserved keyword for #{self.root}"
      end
    end
  end
end