module JsonApiResource
  module Associations
    module Preloaders
      module Distributors
        class DistributorByObjectId < Base

          def assign( targets, results )
            targets.each do |target|
                        
              id = target.id
              
              result = results.select{ |r| r.send(key) == id }

              target._cached_associations ||= {}
              target._cached_associations[name] = post_process result
            end
          end

          def validate_assignability!( results )
            results.each do |obj|
              raise_unless obj.respond_to?(key), "preloading #{root}.#{name} failed: results don't respond to '#{key}'"
            end
          end
        end
      end
    end
  end
end