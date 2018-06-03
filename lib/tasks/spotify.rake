# coding: utf-8
# frozen_string_literal: true

require "slack"

namespace :spotify do
  desc "Update a spotify playlist"
  task update_mix_playlists: :environment do
    email = Setting.spotify_playlist_owner_email
    Setting.spotify_mix_playlists.each do |h|
      SpotifyMixPlaylistUpdater.perform_now(email, h["topic"], h["name"])
    end
  end
end
