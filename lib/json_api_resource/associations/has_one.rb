module JsonApiResource
  module Associations
    class HasOne < Base
      def post_process( value )
        value.first
      end

      def action
        :where
      end

      def association_key( association, opts )
        raise "eff"
      end

      def type
        JsonApiResource::Associations::HAS_ONE
      end
    end
  end
end