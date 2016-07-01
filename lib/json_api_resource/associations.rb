module JsonApiResource
  module Associations
    autoload :Base,         'json_api_resource/associations/base.rb'
    autoload :BelongsTo,    'json_api_resource/associations/belongs_to.rb'
    autoload :HasOne,       'json_api_resource/associations/has_one.rb'
    autoload :HasMany,      'json_api_resource/associations/has_many.rb'
  end
end