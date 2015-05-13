require "redis"

module KissRestClient
  module Caching
    class RedisStore

      def initialize(**attrs)
        attrs[:driver] = :hiredis if attrs[:driver].nil? || attrs[:driver].empty?
        @store = Redis.new(attrs)
      end

      def read(path)
        @store.get(path)
      end

      def write(path, value)
        @store.set(path, value)
      end

    end
  end
end