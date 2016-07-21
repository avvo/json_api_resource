module JsonApiResource
  module Associations
    class HasMany < Base
      def default_action
        :where
      end

      def server_key
        class_name = self.root.to_s.demodulize.underscore
        "#{class_name}_id"
      end

      def callable?( root_instance )
        true
      end

      def query( root_instance )
        { key => root_instance.id }.merge(opts)
      end

      def type
        JsonApiResource::Associations::HAS_MANY
      end
    end
  end
end
