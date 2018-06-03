# coding: utf-8
# frozen_string_literal: true

require "slack"

namespace :spotify do
  desc "Update a spotify playlist"
  task update_playlist: :environment do
    email = Setting.spotify_playlist_owner_email
    PlaylistUpdater.perform_now(email, "topic/海外メディア")
    PlaylistUpdater.perform_now(email, "topic/国内メディア")
  end
end
