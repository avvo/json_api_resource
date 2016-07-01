module JsonApiResource
  module Associations
    class BelongsTo < Base
      class << self
        def action
          :find
        end

        def association_key( association, opts )
          "#{association}_id"
        end
      end
    end
  end
end