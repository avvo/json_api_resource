module JsonApiResource
  module CacheProcessor
    class Base

      class << self 
        def process(action, *args, result)
          result
        end
      end
    end
  end
end
