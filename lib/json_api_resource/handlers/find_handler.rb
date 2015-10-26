module JsonApiResource
  module Handlers
    class FindHandler
      attr_accessor :result

      def initialize(results)
        simplify!(results)
      end

      def simplify!(results)
        result = results.first

        result.meta = results.meta

        result.linked_data = results.try(:linked_data)
      end
    end
  end
end