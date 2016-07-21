module JsonApiResource
  module Associations
    class HasOne < Base
      def post_process( value )
        Array(value).first
      end

      def default_action  
        :where
      end

      def server_key
        class_name = self.root.to_s.demodulize.underscore
        "#{class_name}_id"
      end

      def query( root_instance )
        { key => root_instance.id }.merge(opts)
      end

      def callable?( root_instance )
        true
      end

      def type
        JsonApiResource::Associations::HAS_ONE
      end
    end
  end
end