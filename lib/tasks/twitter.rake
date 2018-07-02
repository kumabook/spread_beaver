# coding: utf-8
# frozen_string_literal: true

require "slack"

def twitter_bot_setting(args)
  Setting.twitter_bots[args.name]
end

def spotify_updater_setting(args)
  Setting.spotify_playlist_updaters[args.name]
end

def spotify_user(email)
  User.find_by(email: email)&.spotify_authentication&.spotify_user
end

namespace :twitter do
  desc "tweet daily hot entry"
  task :tweet_daily_hot_entry, %w[name] => :environment do |_task, args|
    TwitterBot.perform_now("daily_hot_entry", twitter_bot_setting(args))
  end

  desc "tweet weekly hot entry"
  task :tweet_weekly_hot_entry, %w[name] => :environment do |_task, args|
    TwitterBot.perform_now("weekly_hot_entry", twitter_bot_setting(args))
  end

  desc "tweet monthly hot entry"
  task :tweet_monthly_hot_entry, %w[name] => :environment do |_task, args|
    TwitterBot.perform_now("monthly_hot_entry", twitter_bot_setting(args))
  end

  desc "tweet daily hot track"
  task :tweet_daily_hot_track, %w[name] => :environment do |_task, args|
    TwitterBot.perform_now("daily_hot_track", twitter_bot_setting(args))
  end

  desc "tweet weekly hot track"
  task :tweet_weekly_hot_track, %w[name] => :environment do |_task, args|
    TwitterBot.perform_now("weekly_hot_track", twitter_bot_setting(args))
  end

  desc "tweet monthly hot track"
  task :tweet_monthly_hot_track, %w[name] => :environment do |_task, args|
    TwitterBot.perform_now("monthly_hot_track", twitter_bot_setting(args))
  end

  desc "tweet today's chart"
  task :tweet_chart, %w[name index] => :environment do |_task, args|
    index    = args.index.to_i
    options  = { index: index }
    TwitterBot.perform_now("chart_track", twitter_bot_setting(args), options)
  end

  desc "tweet chart spotify playlist"
  task :tweet_chart_spotify_playlist, %w[name mix] => :environment do |_task, args|
    bot_setting     = twitter_bot_setting(args)
    spotify_setting = spotify_updater_setting(args)
    mix_setting     = spotify_setting["mix_playlists"][args.mix]
    email           = spotify_setting["email"]
    options         = { name: mix_setting["name"], user: spotify_user(email) }
    TwitterBot.perform_now("chart_spotify_playlist", bot_setting, options)
  end

  desc "tweet climb up track"
  task :tweet_climb_up_track, %w[name index] => :environment do |_task, args|
    index    = args.index.to_i
    options  = { index: index }
    TwitterBot.perform_now("climb_up_track", twitter_bot_setting(args), options)
  end

  desc "tweet chart"
  task :tweet_chart, %w[name mix] => :environment do |_task, args|
    bot_setting = twitter_bot_setting(args)
    TwitterBot.perform_now("chart", bot_setting)
  end
end
