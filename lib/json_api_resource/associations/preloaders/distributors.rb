module JsonApiResource
  module Associations
    module Preloaders
      module Distributors
        autoload :Base,                   'json_api_resource/associations/preloaders/distributors/base'
        autoload :DistributorByObjectId,  'json_api_resource/associations/preloaders/distributors/distributor_by_object_id'
        autoload :DistributorByTargetId,  'json_api_resource/associations/preloaders/distributors/distributor_by_target_id'
      end
    end
  end
end
