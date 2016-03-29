module JsonApiResource
  module ErrorNotifier
    class Base
      class << self
        def notify( connection, error )
          raise NotImplementedError
        end
      end
    end
  end
end
