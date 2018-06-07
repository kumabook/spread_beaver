# coding: utf-8
# frozen_string_literal: true

require "slack"

namespace :spotify do
  desc "Update a spotify playlist"
  task :update_mix_playlists, %w[name] => :environment do |_task, args|
    setting = Setting.spotify_playlist_updaters[args.name]
    email   = setting["email"]
    setting["mix_playlists"].each do |_id, h|
      SpotifyMixPlaylistUpdater.perform_now(email, h["topic"], h["name"])
    end
  end
end
