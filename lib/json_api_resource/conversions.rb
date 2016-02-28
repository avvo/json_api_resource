module JsonApiResource
  module Conversions
    def ApiErrors(*args)
      case args.first
        when ActiveModel::Errors then args.first
        when Hash then args.first
        when Array then { base: args }
        when String then { base: [args] }
        when NilClass then { base: [[]]}
        else raise TypeError, "Cannot convert #{ args.inspect} to Error"
      end
    end

    def Date(*args)
      case args.first
        when String then Date.parse(args.first)
        when Date then args.first
        else raise TypeError, "Cannot convert #{ args.inspect} to Date"
      end
    end

    def DateTime(*args)
      case args.first
        when String then DateTime.parse(args.first)
        when DateTime then args.first
        else raise TypeError, "Cannot convert #{ args.inspect} to DateTime"
      end
    end

    def Boolean(*args)
      case args.first
        when FalseClass then args.first
        when TrueClass then args.first
        when NilClass then false
        when String
          if %w(true 1).include?(args.first.downcase)
            true
          elsif %w(false 0).include?(args.first.downcase)
            false
          else
            raise TypeError, "Cannot convert #{ args.inspect} to Boolean"
          end
        when Integer then args.first != 0
        else raise TypeError, "Cannot convert #{ args.inspect} to Boolean"
      end
    end

    def ApiResource(klass, *args)
      case args.first
        when klass then args.first
        when Hash then klass.new(args.first)
        when klass.client_class then klass.new(args.first.attributes)
        when Array then args.first.map { |attr| ApiResource(klass, attr) }
        else raise TypeError, "Cannot convert #{ args.inspect} to #{klass}"
      end
    end

    def ResultSet(*args)
      case args.first
        when JsonApiClient::ResultSet then JsonApiResource::ResultSet.build(args.first)
        when Array then JsonApiResource::ResultSet.build(JsonApiClient::ResultSet.new(args.first))
        else raise TypeError, "Cannot convert #{ args.inspect} to ResultSet"
      end
    end
  end
end