module JsonApiResource
  module Associations
    class HasManyPrefetched < Base
      def default_action
        :where
      end

      def server_key
        @opts[:prefetched_ids]
      end

      def query( root_instance )
        { id: root_instance.send(key) }.merge(opts)
      end

      def callable?( root_instance )
        root_instance.send(key).present?
      end

      def nil_default
        []
      end

      def type
        JsonApiResource::Associations::HAS_MANY_PREFETCHED
      end

      def validate_options
        raise_unless key == server_key, "#{root}.#{name} cannot specify both prefetched_ids and a foreign key"
        super
      end
    end
  end
end