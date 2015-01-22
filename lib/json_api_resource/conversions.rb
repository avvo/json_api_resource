module JsonApiResource
  module Conversions
    def Address(*args)
      case args.first
        when Address then args.first
        when Hash then Address.new(args.first)
        when Address.client then Address.new(args.first.attributes)
        when Array then args.first.map { |attr| Address(attr) }
        when Integer then Address.new(* args)
        when String then Address.new(* args.first.split(':'). map(&:to_i))
        else raise TypeError, "Cannot convert #{ args.inspect} to Address"
      end
    end

    def ApiErrors(*args)
      case args.first
        when ActiveModel::Errors then args.first
        when Hash then args.first
        when Array then { base: args }
        when String then { base: [args] }
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

    def Symbolize(*args)
      case args.first
        when String then args.first.underscore.parameterize('_').to_sym
        else args.first
      end
    end

    def ApiResource(klass, *args)
      case args.first
        when klass then args.first
        when Hash then klass.new(args.first)
        when klass.client then klass.new(args.first.attributes)
        when Array then args.first.map { |attr| JsonApiResource(attr, klass) }
        else raise TypeError, "Cannot convert #{ args.inspect} to #{klass}"
      end
    end
  end
end