module JsonApiResource
  module Associations
    module Preloaders
      module Distributors
        class DistributorByTargetId < Base

          def assign( targets, results )
            targets.each do |target|
              
              ids = Array(target.send(key))
              
              # this obejct doesn't have this association. skip
              next unless ids.present?
                
              result = results.select{ |r| ids.include? r.id }

              target._cached_associations ||= {}
              target._cached_associations[name] = post_process result

            end
          end

          def validate_assignability!( results )
            results.each do |obj|
              raise_unless obj.respond_to?(:id), "preloading #{root}.#{name} failed: results don't respond to 'id'"
            end
          end
        end
      end
    end
  end
end