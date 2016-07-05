module JsonApiResource
  module Associations
    class HasOne < Base
      def action
        :where
      end

      def association_key( association, opts )
        raise "eff"
      end

      def type
        JsonApiResource::Associations::HAS_MANY
      end
    end
  end
end