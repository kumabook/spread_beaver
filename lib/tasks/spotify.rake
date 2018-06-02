# coding: utf-8
# frozen_string_literal: true

require "slack"

namespace :spotify do
  desc "Update a spotify playlist"
  task update_playlist: :environment do
    PlaylistUpdater.perform_now("topic/海外メディア")
    PlaylistUpdater.perform_now("topic/国内メディア")
  end
end
