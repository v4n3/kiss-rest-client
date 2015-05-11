module KissRestClient
  module Configuration
    module ClassMethods
      @@base_url = nil

      @@api_auth_key = nil
      @@api_auth_secret = nil

      @@headers = {}

      def base_url(value = nil)
        if value.nil?
          if @base_url.nil?
            @@base_url
          else
            @base_url
          end
        else
          value = value.gsub(/\/$/, '')
          @base_url = value
        end
      end

      def base_url=(value)
        value = value.gsub(/\/+$/, '')
        @@base_url = value
      end

      def headers(key = nil, value = nil)
        if key.nil? && value.nil?
          @@headers
        else
          @@headers ||= {}
          @@headers[key] = value
        end
      end

      def api_auth_credentials(key, secret)
        @@api_auth_key = key
        @@api_auth_secret = secret
      end

      def api_auth_key
        @@api_auth_key
      end

      def api_auth_secret
        @@api_auth_secret
      end

      def _reset_configuration!
        @base_url             = nil
        @@base_url            = nil
        @@api_auth_key  = nil
        @@api_auth_secret = nil
      end

      def collection_name(value=nil)
        if value.nil?
          @collection_name
        else
          @collection_name = value
        end
      end

      def element_name(value=nil)
        if value.nil?
          @element_name
        else
          @element_name = value
        end
      end

    end

    def self.included(base)
      base.extend(ClassMethods)
    end
  end

end