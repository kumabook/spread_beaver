# coding: utf-8
# frozen_string_literal: true

require "slack"

def twitter_bot_setting(args)
  Setting.twitter_bots[args.name]
end

namespace :twitter do
  desc "This task is called by the Heroku scheduler add-on"
  task :tweet_daily_hot_entry, %w[name] => :environment do |_task, args|
    TwitterBot.perform_now("daily_hot_entry", twitter_bot_setting(args))
  end

  desc "This task is called by the Heroku scheduler add-on"
  task :tweet_weekly_hot_entry, %w[name] => :environment do |_task, args|
    TwitterBot.perform_now("weekly_hot_entry", twitter_bot_setting(args))
  end

  desc "This task is called by the Heroku scheduler add-on"
  task :tweet_monthly_hot_entry, %w[name] => :environment do |_task, args|
    TwitterBot.perform_now("monthly_hot_entry", twitter_bot_setting(args))
  end

  desc "This task is called by the Heroku scheduler add-on"
  task :tweet_daily_hot_track, %w[name] => :environment do |_task, args|
    TwitterBot.perform_now("daily_hot_track", twitter_bot_setting(args))
  end

  desc "This task is called by the Heroku scheduler add-on"
  task :tweet_weekly_hot_track, %w[name] => :environment do |_task, args|
    TwitterBot.perform_now("weekly_hot_track", twitter_bot_setting(args))
  end

  desc "This task is called by the Heroku scheduler add-on"
  task :tweet_monthly_hot_track, %w[name] => :environment do |_task, args|
    TwitterBot.perform_now("monthly_hot_track", twitter_bot_setting(args))
  end

  desc "tweet today's chart"
  task :tweet_chart, %w[name index topic_id] => :environment do |_task, args|
    index    = args.index.to_i
    options  = { index: index }
    TwitterBot.perform_now("chart_track", twitter_bot_setting(args), options)
  end
end
