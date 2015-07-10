module JsonApiResource
  class Resource
    include ActiveModel::Model
    include ActiveModel::Validations
    extend  ActiveModel::Callbacks

    include JsonApiResource::Schemable
    include JsonApiResource::Queryable
    include JsonApiResource::Conversions
    include JsonApiResource::Cacheable

    attr_accessor :client, :cache_expires_in
    class_attribute :client_klass, :per_page

    define_model_callbacks :save, :create, :update_attributes

    around_create :catch_errors
    around_save   :catch_errors
    around_update_attributes :catch_errors

    def initialize(opts={})
      self.client = self.client_klass.new(self.schema)
      self.errors = ActiveModel::Errors.new(self)
      self.attributes = opts
    end

    def new_record?
      self.id.nil?
    end

    def persisted?
      !new_record?
    end

    def save
      run_callbacks :save do
        self.client.save
      end
    end

    def attributes=(attr = {})
      client_params = attr.delete(:client)
      if attr.is_a? self.client_klass
        self.client = attr
      elsif client_params
        self.client = client_params
      else
        self.client.attributes = attr
      end
    end

    protected

    def method_missing(method, *args, &block)
      if match = method.to_s.match(/^(.*=)$/)
        self.client.send(match[1], args.first)
      elsif self.client.respond_to?(method.to_sym)
        is_method = self.client.methods.include?(method.to_sym)
        argument_count = (is_method ? self.client.method(method.to_sym).arity : 0)
        argument_count = args.length if argument_count == -1
        if (argument_count == 0) || args.blank?
          self.client.send(method)
        else
          self.client.send(method, *args.take(argument_count))
        end
      else
        super
      end
    end

    def catch_errors
      yield

      self.errors ||= ActiveModel::Errors.new(self)
      ApiErrors(self.client.errors).each do | k,messages|
        self.errors.add(k.to_sym, Array(messages).join(', '))
      end
      self.errors
    end

    def self.method_missing(method, *args, &block)
      if match = method.to_s.match(/^(.*)=$/)
        self.client_klass.send(match[1], args.first)
      elsif self.client_klass.respond_to?(method.to_sym)
        self.client_klass.send(method, *args)
      else
        super
      end
    end
  end
end