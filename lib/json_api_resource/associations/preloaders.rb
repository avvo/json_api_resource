module JsonApiResource
  module Associations
    module Preloaders
      autoload :Base,                         'json_api_resource/associations/preloaders/base'
      autoload :BelongsToPreloader,           'json_api_resource/associations/preloaders/belongs_to_preloader'
      autoload :Distributors,                 'json_api_resource/associations/preloaders/distributors'
      autoload :HasManyPrefetchedPreloader,   'json_api_resource/associations/preloaders/has_many_prefetched_preloader'
      autoload :HasManyPreloader,             'json_api_resource/associations/preloaders/has_many_preloader'
      autoload :HasOnePreloader,              'json_api_resource/associations/preloaders/has_one_preloader'
    end
  end
end