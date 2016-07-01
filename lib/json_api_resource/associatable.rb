module JsonApiResource
  module Associatable
    extend ActiveSupport::Concern

    included do
      class << self
        def belongs_to( name, opts = {} )
          association = Associations::BelongsTo.create( name, opts )
          associate name, association
        end

        def has_one( name, opts = {} )
          association = Associations::HasOne.create( name, opts )
          associate name, association
        end

        def has_many( name, opts = {} )
          association = Associations::HasMany.create( name, opts )
          associate name, association
        end

        private

        def associate( name, association )
          define_method(name, association)
        end
      end

      attr_accessor :_cached_associations

      # self._cached_associations = {}
    end
  end
end

