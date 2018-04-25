# frozen_string_literal: true
require "redis"
Redis.current = Redis.new(:host => ENV["REDIS_URL"] || "127.0.0.1")
