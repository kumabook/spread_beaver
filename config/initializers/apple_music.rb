# frozen_string_literal: true

require "apple_music"

AppleMusic.configure do |client|
  client.developer_token = ENV["APPLE_MUSIC_DEVELOPER_TOKEN"]
end
