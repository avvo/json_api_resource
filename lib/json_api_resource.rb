require 'json_api_client'

module JsonApiResource
  autoload :Cacheable,              'json_api_resource/cacheable'
  autoload :Clientable,             'json_api_resource/clientable'
  autoload :Connections,            'json_api_resource/connections'
  autoload :Conversions,            'json_api_resource/conversions'
  autoload :ErrorHandleable,        'json_api_resource/error_handleable'
  autoload :ErrorNotifier,          'json_api_resource/error_notifier'
  autoload :Handlers,               'json_api_resource/handlers'
  autoload :Errors,                 'json_api_resource/errors'
  autoload :Queryable,              'json_api_resource/queryable'
  autoload :Resource,               'json_api_resource/resource'
  autoload :Executable,             'json_api_resource/executable'
  autoload :Schemable,              'json_api_resource/schemable'
end