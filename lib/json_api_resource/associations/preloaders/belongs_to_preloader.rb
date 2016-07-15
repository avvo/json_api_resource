module JsonApiResource
  module Associations
    module Preloaders
      class BelongsToPreloader < Base

        def bulk_query( objects )
          ids = objects.map{ |o| o.send(key) }.flatten.uniq
          { id: ids }.merge(opts)
        end

        def distributor_class
          JsonApiResource::Associations::Preloaders::Distributors::DistributorByTargetId
        end
      end
    end
  end
end
