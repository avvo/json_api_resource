module JsonApiResource
  module Associations
    class Base
      class << self
        def create(associated_class, association, opts)
          assoc_builder = self

          assoc_class   = association_class( associated_class, association, opts )
          assoc_key     = assoc_builder.association_key( association, opts )
          assoc_action  = self.action
          assoc_process = lambda {|value| post_process(value) }
          
          method = lambda do 
            unless _cached_associations.has_key? association

              result = assoc_class.send( assoc_action, assoc_key, opts )
              result = assoc_process result
              
              _cached_associations[association] = result
            end
            _cached_associations[association]
          end

          associated_class.send :define_method, association, method
        end

        protected

        def action
          raise NotImplementedError
        end

        def post_process( value )
          value
        end

        def association_key( association, opts )
          raise NotImplementedError
        end

        def association_class( associated_class, association, opts )
          opts[:class] || derived_class( associated_class, association )
        end

        def derived_class( associated_class, association )
          module_string = associated_class.to_s.split("::")[0 ... -1].join("::")
          class_string  = association.to_s.singularize.camelize
          
          # we don't necessarily want to add :: to classes, in case they have a relative path or something
          class_string = [module_string, class_string].select{|s| s.present? }.join "::"
          class_string.constantize
        end
      end
    end
  end
end