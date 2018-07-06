# coding: utf-8
# frozen_string_literal: true

require "slack"

class SpotifyMixPlaylistUpdater < ApplicationJob
  queue_as :default

  def perform(*args)
    logger.info("SpotifyMixPlaylistUpdater start")
    email    = args[0]
    topic_id = args[1]
    name     = args[2]
    user     = User.find_by(email: email)
    topic    = Topic.find(topic_id)
    playlist = SpotifyMixPlaylistUpdater.update_playlist(user, topic, name)
    logger.info("Update playlist #{playlist.name}")
    logger.info("SpotifyMixPlaylistUpdater end")
    notify_slack("Update playlist #{playlist.name}")
    playlist
  end

  def self.update_playlist(user, topic, name)
    authentication = user.spotify_authentication
    spotify_user   = authentication.spotify_user
    playlist_name  = name
    playlist       = find_or_create_spotify_playlist(spotify_user, playlist_name)
    Rails.logger.info("#{playlist_name} is created")
    tracks = chart_tracks(topic).select do |track|
      track.provider == "Spotify"
    end
    clear_playlist(playlist)
    add_tracks_to_spotify_playlist(playlist, tracks)
    authentication.update(credentials: spotify_user.credentials.to_json)
    playlist
  end

  def self.chart_tracks(topic)
    today            = Time.zone.now.beginning_of_day
    week_ago         = today - 7.days
    entries_per_feed = Setting.latest_entries_per_feed
    query = Mix::Query.new(week_ago..today, :engaging, entries_per_feed: entries_per_feed)
    tracks = topic.mix_enclosures(Track, page: 1, per_page: 100, query: query)
    Track.set_contents(tracks)
    tracks
  end

  def self.clear_playlist(playlist)
    tracks = playlist.tracks(offset: 0, limit: 100)
    playlist.remove_tracks!(tracks)
  end

  def self.add_tracks_to_spotify_playlist(playlist, tracks)
    tracks.map(&:identifier).in_groups_of(50, false) do |ids|
      spotify_tracks = RSpotify::Track.find(ids)
      playlist.add_tracks!(spotify_tracks)
    end
  end

  def self.find_or_create_spotify_playlist(user, name)
    playlist = user.playlists(offset: 0, limit: 50).find { |v| v.name == name }
    return playlist if playlist.present?
    user.create_playlist!(name)
  end
end
