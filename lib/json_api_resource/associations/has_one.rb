module JsonApiResource
  module Associations
    class HasOne < Base
      class << self
        def post_process( value )
          value.first
        end

        def action
          raise :find
        end

        def association_key( association, opts )
          raise "eff"
        end
      end
    end
  end
end