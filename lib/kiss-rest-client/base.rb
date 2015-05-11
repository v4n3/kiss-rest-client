module KissRestClient
  class Base
    include Configuration
    include HttpClient

    def initialize(attrs={})
      @attributes = {}

      raise Exception.new("Cannot instantiate Base class") if self.class.name == "KissRestClient::Base"

      attrs.each do |attribute_name, attribute_value|
        attribute_name = attribute_name.to_sym
        @attributes[attribute_name] = attribute_value
      end
    end

    def attributes
      @attributes
    end

    def [](key)
      @attributes[key.to_sym]
    end

    def []=(key, value)
      @attributes[key.to_sym] = value
    end

    def each
      @attributes.each do |key, value|
        yield key, value
      end
    end

    def to_hash
      output = {}
      @attributes.each do |key, value|
        if value.is_a? KissRestClient::Base
          output[key.to_s] = value.to_hash
        elsif value.is_a? Array
          output[key.to_s] = value.map(&:to_hash)
        else
          output[key.to_s] = value
        end
      end
      output
    end

    def to_json
      output = to_hash
      output.to_json
    end

  end
end