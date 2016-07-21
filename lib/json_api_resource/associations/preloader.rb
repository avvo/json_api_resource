module JsonApiResource
  module Associations
    class Preloader
      include JsonApiResource::Errors

      class << self
        def preload ( objects, preloads )
          objects  = Array(objects)
          preloads = Array(preloads)
          
          preloads.each do |preload|

            association = association_for objects, preload
            
            preloader   = preloader_for association

            preloader.preload( objects )

          end
        end

        private

        def association_for( objects, preload )
          # let's assert the objects are of a single class
          verify_object_homogenity!(objects)

          obj_class   = objects.first.class
          association = obj_class._associations[preload]
          
          raise_if association.nil?, "'#{preload}' is not a valid association on #{obj_class}"

          association
        end

        def preloader_for( association )
          preloader_class = PREOLOADERS_FOR_ASSOCIATIONS[association.type]
          preloader_class.new association
        end

        def verify_object_homogenity!( objects )
          obj_class = objects.first.class
          
          objects.each do |obj|
            raise_unless obj.is_a?(obj_class), "JsonApiResource::Associations::Preloader.preload called with a heterogenious array of objects."
          end
        end

        PREOLOADERS_FOR_ASSOCIATIONS = {
                                          JsonApiResource::Associations::BELONGS_TO          => JsonApiResource::Associations::Preloaders::BelongsToPreloader,
                                          JsonApiResource::Associations::HAS_ONE             => JsonApiResource::Associations::Preloaders::HasOnePreloader,
                                          JsonApiResource::Associations::HAS_MANY            => JsonApiResource::Associations::Preloaders::HasManyPreloader,
                                          JsonApiResource::Associations::HAS_MANY_PREFETCHED => JsonApiResource::Associations::Preloaders::HasManyPrefetchedPreloader,
                                        }
      end
    end
  end
end