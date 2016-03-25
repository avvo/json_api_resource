module JsonApiResource
  module Connections
    class CacheHandler

      class << self 
        attr_accessor :cache

        def cache_result(key, result)