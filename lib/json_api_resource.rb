require 'json_api_client'

module JsonApiResource
  autoload :Cacheable,              'json_api_resource/cacheable'
  autoload :Clientable,             'json_api_resource/clientable'
  autoload :Connections,            'json_api_resource/connections'
  autoload :Conversions,            'json_api_resource/conversions'
  autoload :ErrorNotifier,          'json_api_resource/error_notifier'
  autoload :Handlers,               'json_api_resource/handlers'
  autoload :JsonApiResourceError,   'json_api_resource/json_api_resource_error'
  autoload :Queryable,              'json_api_resource/queryable'
  autoload :Resource,               'json_api_resource/resource'
  autoload :Executable,             'json_api_resource/executable'
  autoload :Schemable,              'json_api_resource/schemable'
end