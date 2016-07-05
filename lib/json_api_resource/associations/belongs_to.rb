module JsonApiResource
  module Associations
    class BelongsTo < Base
      def action
        :find
      end

      def server_key( association, opts )
        "#{association}_id"
      end

      def type
        JsonApiResource::Associations::BELONGS_TO
      end
    end
  end
end