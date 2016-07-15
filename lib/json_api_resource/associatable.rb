module JsonApiResource
  module Associatable
    extend ActiveSupport::Concern

    included do

      class_attribute :_associations
      self._associations = {}

      attr_accessor :_cached_associations      
      
      class << self
        def belongs_to( name, opts = {} )
          process Associations::BelongsTo.new( self, name, opts )
        end

        def has_one( name, opts = {} )
          process Associations::HasOne.new( self, name, opts )
        end

        def has_many( name, opts = {} )
          if opts[:prefetched_ids]
            process Associations::HasManyPrefetched.new( self, name, opts )
          else
            process Associations::HasMany.new( self, name, opts )
          end
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
          define_method association.name do 
            self._cached_associations ||= {}
            unless self._cached_associations.has_key? association.name
              if association.callable?(self)
                result = association.klass.send( association.action, association.query(self) )
                result = association.post_process result
              else
                result = association.nil_default
              end
              
              self._cached_associations[association.name] = result
            end
            self._cached_associations[association.name]
          end
        end
      end
    end
  end
end

