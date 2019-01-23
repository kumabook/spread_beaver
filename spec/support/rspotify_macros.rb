# frozen_string_literal: true

require "rspotify_helper"

module RSpotifyMacros
  def mock_up_rspotify
    allow(RSpotify::Track).to receive(:find) do |id|
      RSpotify::Track.new(RSpotifyHelper.track_hash(id))
    end
    allow(RSpotify::Album).to receive(:find) do |id|
      RSpotify::Album.new(RSpotifyHelper.album_hash(id))
    end
  end
end
