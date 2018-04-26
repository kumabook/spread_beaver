# frozen_string_literal: true

class PlaylistCrawler < ApplicationJob
  queue_as :default

  def perform
    logger.info("PlaylistCrawler start")
    info = crawl()
    logger.info("PlaylistCrawler end")
    {
      info:    info,
      message: "#{info[:total_tracks]} tracks from #{info[:total_playlists]}"
    }
  end

  def crawl
    playlists = Playlist.fetch_actives()
    logger.info("There are #{playlists.count} active playlists")
    info = {
      total_playlists: playlists.count,
      total_tracks:    0,
    }
    playlists.each do |playlist|
      logger.info("Fetching tracks of #{playlist.title}")
      tracks = playlist.fetch_tracks()
      logger.info("There are #{tracks.count} tracks in #{playlist.title}")
      info = info.merge({
                          total_tracks: info[:total_tracks] + tracks.count
                        })
      logger.info("Fetched tracks of #{playlist.title}")
    end
    info
  end
end
