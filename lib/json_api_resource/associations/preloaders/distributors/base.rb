module JsonApiResource
  module Associations
    module Preloaders
      module Distributors
        class Base
          include JsonApiResource::Errors

          attr_accessor :association
          delegate :key, :post_process, :root, :name, to: :association

          def initialize(association)
            self.association = association
          end

          def distribute( targets, resutls )
            validate_assignability!( resutls )
            assign( targets, resutls )
          end

          private

          def validate_assignability!( resutls )
            raise NotImplementedError
          end

          def assign( targets, resutls )
            raise NotImplementedError
          end
        end
      end
    end
  end
end