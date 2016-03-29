module JsonApiResource
  module Connections
    autoload :CacheFallbackConnection,  'json_api_resource/connections/cache_handler'
    autoload :Keyable,                  'json_api_resource/connections/keyable'
    autoload :ServerConnection,         'json_api_resource/connections/server_connection'
  end
end