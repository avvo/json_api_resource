module JsonApiResource
  module Handlers
    class FindHandler
      attr_accessor :result

      def initialize(results)
        self.result = results.first

        self.result.meta = results.meta

        self.result.linked_data = results.try(:linked_data)
      end
    end
  end
end