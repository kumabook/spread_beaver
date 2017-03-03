# coding: utf-8
namespace :twitter do
  desc "This task is called by the Heroku scheduler add-on"
  task :tweet_hot_entry => :environment do
    puts "Start making tweet of hot entry"
    client = get_twitter_client
    tweet  = get_hot_entry_tweet
    update(client, tweet) if tweet.present?
  end

  desc "This task is called by the Heroku scheduler add-on"
  task :tweet_popular_track => :environment do
    puts "Start making tweet of popular track"
    client = get_twitter_client
    tweet  = get_popular_track_tweet
    update(client, tweet) if tweet.present?
  end
end

def get_twitter_client
  Twitter::REST::Client.new do |config|
    config.consumer_key        = Setting.twitter_consumer_key
    config.consumer_secret     = Setting.twitter_consumer_secret
    config.access_token        = Setting.twitter_access_token
    config.access_token_secret = Setting.twitter_access_secret
  end
end

def get_hot_entry_tweet
  duration = Setting.duration_for_ranking.days
  from     = duration.ago
  to       = from + duration
  entries = Entry.hot_entries_within_period(from: from, to: to)

  if entries.blank?
    puts "Not found hot entries."
    return
  end

  entry  = entries[0]
  origin = JSON.load(entry.origin)

  if origin.present? && origin['title'].present?
    body  = "✏[Today's Hot Entry] #{entry.title} by #{origin['title']}"
    body  = (body.length > 116) ? body[0..115].to_s : body
    tweet = "#{body} #{entry.originId}"
    tweet.chomp
  else
    puts "Not found origin of entry."
    nil
  end
end

def get_popular_track_tweet
  duration = Setting.duration_for_ranking.days
  from     = duration.ago
  to       = from + duration
  tracks   = Track.popular_items_within_period(from: from, to: to, page: 1, per_page: 1)

  if tracks.blank?
    puts "Not found popular tracks."
    return
  end

  track = tracks[0]

  if title.present? && url.present?
    body  = "🎧[Today's Hot Track] #{track.title}"
    body  = (body.length > 116) ? body[0..115].to_s : body
    tweet = "#{body} #{track.url}"
    tweet.chomp
  else
    puts "Not found title or url of track."
    nil
  end
end

def update(client, tweet)
  client.update(tweet.chomp)
  puts tweet
rescue => e
  Rails.logger.error "<<twitter.rake::tweet.update ERROR : #{e.message}>>"
end
