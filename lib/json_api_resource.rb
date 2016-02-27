require 'json_api_client'

module JsonApiResource
  autoload :Cacheable,              'json_api_resource/cacheable'
  autoload :Clientable,             'json_api_resource/clientable'
  autoload :Conversions,            'json_api_resource/conversions'
  autoload :Handlers,               'json_api_resource/handlers'
  autoload :JsonApiResourceError,   'json_api_resource/json_api_resource_error'
  autoload :Queryable,              'json_api_resource/queryable'
  autoload :Resource,               'json_api_resource/resource'
  autoload :Requestable,            'json_api_resource/requestable'
  autoload :Schemable,              'json_api_resource/schemable'
end