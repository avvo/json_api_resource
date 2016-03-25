module JsonApiResource
  module Connections
    module Keyable
      extend ActiveSupport::Concern

      included do
        def cache_key(client, action, args)
          # this can come in as a class or as an instance
          #                                       class    |     instance
          class_string = client.is_a?(Class) ? client.to_s : client.class.to_s
          "#{class_string}/#{action}/#{ordered_args(args)}"
        end

        def ordered_args(args)
          args.sort.to_h
        end
      end
    end
  end
end