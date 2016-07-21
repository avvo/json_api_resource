module JsonApiResource
  module Associations
    autoload :Base,               'json_api_resource/associations/base'
    autoload :BelongsTo,          'json_api_resource/associations/belongs_to'
    autoload :HasManyPrefetched,  'json_api_resource/associations/has_many_prefetched'
    autoload :HasOne,             'json_api_resource/associations/has_one'
    autoload :HasMany,            'json_api_resource/associations/has_many'
    autoload :Preloader,          'json_api_resource/associations/preloader'
    autoload :Preloaders,         'json_api_resource/associations/preloaders'


    BELONGS_TO          = :belongs_to
    HAS_ONE             = :has_one
    HAS_MANY            = :has_many
    HAS_MANY_PREFETCHED = :has_many_prefetched
  end
end