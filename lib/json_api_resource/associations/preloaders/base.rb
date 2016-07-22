module JsonApiResource
  module Associations
    module Preloaders
      class Base
        include JsonApiResource::Errors

        attr_accessor :association, :distributor
        delegate :klass, :name, :action, :key, :opts, :post_process, to: :association

        def initialize(association)
          self.association = association
          self.distributor = distributor_class.new association
        end

        def preload( objects )
          query       = bulk_query( objects )
          if safe? query
            results     = klass.send action, query
          else
            results     = []
          end

          distributor.distribute objects, results
        end

        private

        def safe?( query )
          raise NotImplementedError
        end

        def assign( objects, results )
          raise NotImplementedError
        end

        def bulk_query( objects )
          raise NotImplementedError
        end

        def distributor_class
          raise NotImplementedError
        end
      end
    end
  end
end