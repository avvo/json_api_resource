module JsonApiResource
  module Associations
    module Preloaders
      class HasOnePreloader < Base

        def bulk_query( objects )
          ids = objects.map(&:id)
          { key => ids }.merge(opts)
        end

        def distributor_class
          JsonApiResource::Associations::Preloaders::Distributors::DistributorByObjectId
        end
      end
    end
  end
end
