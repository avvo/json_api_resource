require 'active_support'
require 'active_support/callbacks'
require 'active_support/concern'
require 'active_support/core_ext/module'
require 'active_support/core_ext/class/attribute'
require 'active_model'
require 'active_model/model'
require 'active_model/validations'
require 'active_model/callbacks'

module JsonApiResource
  class Resource
    include ActiveModel::Model
    include ActiveModel::Validations
    extend  ActiveModel::Callbacks

    extend ActiveSupport::Callbacks

    include JsonApiResource::Clientable
    include JsonApiResource::Schemable
    include JsonApiResource::Requestable
    include JsonApiResource::Queryable
    include JsonApiResource::Conversions
    include JsonApiResource::Cacheable

    attr_accessor :client, :cache_expires_in
    class_attribute :per_page

    def initialize(opts={})
      raise( JsonApiResourceError, class: self.class, message: "A resource must have a client class" ) unless client_class.present?

      self.client = self.client_class.new(self.schema)
      self.errors = ActiveModel::Errors.new(self)
      self.attributes = opts
    end

    def new_record?
      self.id.nil?
    end

    def persisted?
      !new_record?
    end

    def attributes=(attr = {})
      client_params = attr.delete(:client)
      if attr.is_a? self.client_class
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

    rescue JsonApiClient::Errors::ServerError => e
      self.class.pretty_error e
    end

    def self.method_missing(method, *args, &block)
      if match = method.to_s.match(/^(.*)=$/)
        self.client_class.send(match[0], args.first)
       
      elsif self.client_class.respond_to?(method.to_sym)
        results = self.client_class.send(method, *args)

        if results.is_a? JsonApiClient::ResultSet
          results.map do |result|
            self.new(:client => result)
          end
        end

      else
        super
      end
    end

    def respond_to_missing?(method_name, include_private = false)
      client.respond_to?(method_name.to_sym) || super
    end

    def self.respond_to_missing?(method_name, include_private = false)
      client_class.respond_to?(method_name.to_sym) || super
    end
  end
end