module JsonApiResource
  module Associations
    class Base
      class << self
        def create(association, opts)
          assoc_class   = self.association_class( association, opts )
          assoc_key     = self.association_key( association, opts )
          assoc_builder = self

          lambda do 
            unless _cached_associations.has_key? association
              puts assoc_class, assoc_builder.action, assoc_key, opts
              result = assoc_class.send( assoc_builder.action, assoc_key, opts )
              result = assoc_builder.post_process result
              
              _cached_associations[association] = result
            end
            _cached_associations[association]
          end
        end

        def action
          raise NotImplementedError
        end

        def post_process( value )
          value
        end

        protected

        def association_key( association, opts )
          raise NotImplementedError
        end

        def association_class( association, opts )
          opts[:class] || derived_class( association )
        end

        def derived_class( association )
          module_string = to_s.split("::")[0 ... -1].join("::")
          class_string  = association.to_s.singularize.camelize
          
          # we don't necessarily want to add :: to classes, in case they have a relative path or something
          class_stirng = [module_string, class_string].select{|s| s.present? }.join "::"
          class_string.constantize
        end
      end
    end
  end
end