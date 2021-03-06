module JsonApiResource
  module Associations
    class Base
      include ::JsonApiResource::Errors
      attr_accessor :name, :action, :key, :root

      def initialize(associated_class, name, opts = {})
        self.name   = name.to_sym
        self.root   = associated_class
        @opts       = opts.merge( skip_pagination: true )
        
        self.action = @opts.delete :action       do default_action end
        self.key    = @opts.delete :foreign_key  do server_key end

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
        @klass ||= begin
          klass = @opts.delete(:class_name).try :constantize
          klass || @opts.delete( :class ) do derived_class end
        end
      end

      def post_process( value )
        value
      end

      def opts
        @opts.except *ASSOCIATION_OPTS
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

      ASSOCIATION_OPTS  = [:class, :action, :foreign_key, :prefetched_ids, :class_name]

      RESERVED_KEYWORDS = [:attributes, :_associations, :_cached_associations, :schema, :client]

      def validate_options
        raise_unless action.present?, "Invalid action: #{self.root}.#{name}"
        raise_unless    key.present?, "Invalid foreign_key for #{self.root}.#{name}"

        raise_if RESERVED_KEYWORDS.include?(name), "'#{name}' is a reserved keyword for #{self.root}"
      end
    end
  end
end