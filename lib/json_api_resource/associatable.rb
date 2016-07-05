module JsonApiResource
  module Associatable
    extend ActiveSupport::Concern

    included do

      class_attribute :associations
      self.associations = {}

      attr_accessor :_cached_associations

      class << self
        def belongs_to( name, opts = {} )
          process Associations::BelongsTo.new( self, name, opts )
        end

        def has_one( name, opts = {} )
          process Associations::HasOne.new( self, name, opts )
        end

        def has_many( name, opts = {} )
          process Associations::HasMany.new( self, name, opts )
        end

        private

        def process(association)
          add_association association
          methodize association
        end

        def add_association(association)
          self._associations = _associations.merge association.name => association
        end

        def methodize( association )
          
          method = lambda do 
            unless _cached_associations.has_key? association.name
              result = association.klass.send( association.action, association.key, opts )
              result = association.process result
              
              _cached_associations[association.name] = result
            end
            _cached_associations[association.name]
          end

          associated_class.send :define_method, association, method
        end
      end
    end
  end
end

