require 'json'

module KissRestClient
  module Caching
    module ClassMethods

      def caching(value = nil)
        return @caching || !cache_store.nil? if value.nil?

        @caching = value
      end

      def cache_store(store=nil, **options)
        if store.nil? || store.empty?
          @@cache_store rescue nil
        else
          begin
            name = "#{store.to_s}_store"
            require "#{File.dirname(__FILE__)}/caching/#{name.downcase}.rb"
            @@cache_store = KissRestClient::Caching.const_get(name.classify).new(options)
          rescue Exception => e
            raise InvalidCacheStoreException.new("CacheStore: ##{store} is not supported")
          end
        end
      end

      def read_cache(path)

        return unless cache_store && caching

        data = cache_store.read(path)

        data = JSON.parse(data) rescue data
      end

      def write_cache(path, response)
        return unless caching && cache_store
        return unless response.code == 200

        if cache_store && response.headers["etag"]

          cached_response = {
            code: response.code,
            parsed_response: response.parsed_response,
            etag: response.headers["etag"]
          }

          cache_store.write(path, cached_response.to_json)
        end
      end
    end

    def self.included(base)
      base.extend(ClassMethods)
    end

  end

  class InvalidCacheStoreException < StandardError ; end
end