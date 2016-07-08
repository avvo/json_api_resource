module JsonApiResource
  module Associations
    class BelongsTo < Base
      def default_action
        :find
      end

      def server_key
        "#{name}_id"
      end

      def query(root_instance)
        root_instance.id
      end

      def type
        JsonApiResource::Associations::BELONGS_TO
      end
    end
  end
end