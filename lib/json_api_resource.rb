require 'active_model/model'
require 'active_model/validations'
require 'active_model/callback'
require 'json_api_client'

module JsonApiResource
  autoload :Conversions,  'json_api_resource/conversions'
  autoload :Queryable,    'json_api_resource/queryable'
  autoload :Schemable,    'json_api_resource/schemable'
  autoload :Resource,     'json_api_resource/resource'
  autoload :Cacheable,    'json_api_resource/cacheable'
end