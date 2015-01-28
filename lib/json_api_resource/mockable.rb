module JsonApiResource
  module Mockable
    extend ActiveSupport::Concern
    class << self
      delegate :set_test_results, to: :client_klass
    end
  end
end