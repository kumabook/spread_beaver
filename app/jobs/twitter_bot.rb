# coding: utf-8
# frozen_string_literal: true

require "slack"

class TwitterBot < ApplicationJob
  queue_as :default

  def perform(*args)
    logger.info("TwitterBot start")

    type    = args[0]
    setting = args[1]
    options = args[2]

    user    = User.find_by(email: setting["email"])
    auth    = user.twitter_authentication
    client  = auth.twitter_client
    topic   = Topic.find(setting["topic"])
    @locale = setting["locale"]
    result  = tweets(type, topic, options).each do |tweet|
      post_tweet(client, tweet, auth.nickname)
    end

    logger.info("TwitterBot end")
    result
  end

  def t(key, options = {})
    options[:locale] = @locale
    I18n.t("twitter_bot.#{key}", options)
  end

  def tweets(type, topic, options)
    case type
    when "daily_hot_entry"
      hot_entry_tweets(topic, 1.day , 1, t("daily"))
    when "weekly_hot_entry"
      hot_entry_tweets(topic, 7.days, 3, t("weekly"))
    when "monthly_hot_entry"
      hot_entry_tweets(topic, 30.days, 10, t("monthly"))
    when "daily_hot_track"
      hot_track_tweets(topic, 1.day, 1, t("daily"))
    when "weekly_hot_track"
      hot_track_tweets(topic, 7.days, 3, t("weekly"))
    when "monthly_hot_track"
      hot_track_tweets(topic, 30.days, 10, t("monthly"))
    when "chart_track"
      index = options[:index]
      track = chart_tracks(topic)[index]
      [build_chart_track_tweet(track, topic, index)]
    when "chart"
      [build_chart_tweet(chart_tracks(topic))]
    when "chart_spotify_playlist"
      playlist = find_or_create_spotify_playlist(options[:user], options[:name])
      [build_chart_spotify_playlist_tweet(playlist)]
    when "climb_up_track"
      index = options[:index]
      track = climb_up_tracks(topic)[index]
      [build_climb_up_track(track)]
    else
      []
    end
  end

  def hot_entry_tweets(topic, duration, count, label)
    hot_entries(topic, duration, count).map.with_index { |entry, index|
      build_hot_entry_tweet(entry, label, index)
    }
  end

  def hot_track_tweets(topic, duration, count, label)
    hot_tracks(topic, duration, count).map.with_index { |entry, index|
      build_hot_track_tweet(entry, label, index)
    }
  end

  def post_tweet(client, tweet, name)
    client.update(tweet.chomp)
    message = "@#{name} tweeted:\n#{tweet}"
    Rails.logger.info(message)
    notify_slack message
  rescue StandardError => e
    Rails.logger.error "<<twitter.rake::tweet.update ERROR : #{e.message}>>"
    notify_slack "@#{name} failed to tweet : #{e.message}"
  end

  def hot_entries(topic, duration = 1, count = 1)
    from             = duration.ago
    to               = from + duration
    entries_per_feed = Setting.latest_entries_per_feed
    query = Mix::Query.new(from..to, :hot, entries_per_feed: entries_per_feed)
    Entry.hot_items(stream: topic, query: query, per_page: count)
  end

  def hot_tracks(topic, duration = 1, count = 1)
    from  = duration.ago
    to    = from + duration
    query = Mix::Query.new(from..to, :hot)
    tracks = Track.hot_items(stream: topic, query: query, per_page: count)
    Track.set_contents(tracks)
    tracks
  end

  def chart_tracks(topic)
    SpotifyMixPlaylistUpdater.chart_tracks(topic)
  end

  def climb_up_tracks(topic)
    today            = Time.zone.now.beginning_of_day
    week_ago         = today - 7.days
    entries_per_feed = Setting.latest_entries_per_feed
    query = Mix::Query.new(week_ago..today, :engaging, entries_per_feed: entries_per_feed)
    tracks   = topic.mix_enclosures(Track, page: 1, per_page: 100, query: query)
    previous = topic.mix_enclosures(Track, page: 1, per_page: 100, query: query.previous(1.day))
    Track.set_contents(tracks)
    Track.set_previous_ranks(tracks, previous)
    tracks.map.with_index { |val, index|
      rank          = index + 1
      previous_rank = val.previous_rank || 100
      val.rank      = rank
      [val, previous_rank - rank]
    }.sort { |a, b|
      b[1] <=> a[1]
    }.map { |val, _rank_diff|
      val
    }
  end

  def find_or_create_spotify_playlist(user, name)
    SpotifyMixPlaylistUpdater.find_or_create_spotify_playlist(user, name)
  end

  def build_entry_tweet(entry, header)
    origin = JSON.load(entry.origin)
    if origin.present? && origin["title"].present?
      body = "#{header} #{entry.title} by #{origin['title']}"
      TwitterBot.truncate_tweet(body, suffix: entry.url)
    else
      Rails.logger.info("Not found origin of entry.")
      nil
    end
  end

  def build_track_tweet(track, prefix)
    body  = "#{prefix} #{track.title} / #{track.content['owner_name']}"
    TwitterBot.truncate_tweet(body, suffix: track.web_url)
  end

  def build_hot_entry_tweet(entry, label, index)
    prefix = t("hot_entry_tweet", { rank: index + 1, label: label })
    build_entry_tweet(entry, prefix)
  end

  def build_hot_track_tweet(track, label, index)
    prefix = t("hot_track_tweet", { rank: index + 1, label: label })
    build_track_tweet(track, prefix)
  end

  def build_chart_track_tweet(track, topic, index)
    prefix = t("chart_track_tweet", rank: index + 1, chart_name: t(topic.id, default: topic.label))
    build_track_tweet(track, prefix)
  end

  def build_chart_tweet(tracks)
    params = tracks[0..5].each_with_index.reduce({}) do |h, (t, i)|
      h["name#{i+1}".to_sym] = t.title
      h["artist_name#{i+1}".to_sym] = t.content["owner_name"]
      h
    end
    params[:date] = Date.current.strftime("%m/%d")
    url = t("chart_url")
    TwitterBot.truncate_tweet(t("chart_tweet", params), suffix: url)
  end

  def build_chart_spotify_playlist_tweet(playlist)
    body  = t("chart_spotify_playlist_tweet", { name: playlist.name })
    TwitterBot.truncate_tweet(body, suffix: playlist.external_urls["spotify"])
  end

  def build_climb_up_track(track)
    body  = t("climb_up_track_tweet", {
                artist:         track.content["owner_name"],
                track:          track.title,
                rank:           track.rank,
                playlist_count: track.pick_count,
              })
    TwitterBot.truncate_tweet(body, suffix: track.web_url)
  end

  def self.truncate_tweet(body, suffix: "")
    parse_result = Twitter::TwitterText::Validation.parse_tweet("#{suffix}\n#{body}")

    return "#{body}\n#{suffix}" if parse_result[:valid]

    body_end = parse_result[:valid_range_end] - suffix.length
    "#{body.truncate(body_end)}\n#{suffix}"
  end
end
