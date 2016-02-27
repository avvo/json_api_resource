module JsonApiResource
  class JsonApiResourceError < StandardError
    def initialize(opts = {})
      @klass    = opts.fetch :class, JsonApiResource::Resource
      @message  = opts.fetch :message, ""
    end

    def message
      "#{@klass}: #{@message}"
    end
  end
end