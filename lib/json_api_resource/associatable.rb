module JsonApiResource
  module Associatable
    extend ActiveSupport::Concern

    included do
      class << self
        def belongs_to( name, opts = {} )
          Associations::BelongsTo.create( self, name, opts )
        end

        def has_one( name, opts = {} )
          Associations::HasOne.create( self, name, opts )
        end

        def has_many( name, opts = {} )
          Associations::HasMany.create( self, name, opts )
        end
      end

      attr_accessor :_cached_associations

      # self._cached_associations = {}
    end
  end
end

