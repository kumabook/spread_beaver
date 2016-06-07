namespace :twitter do
  desc "This task is called by the Heroku scheduler add-on"
  puts "Start making tweet of hot entry"
  task :tweet_hot_entry => :environment do
  	client = get_twitter_client
  	tweet  = get_hot_entry_tweet
  	update(client, tweet)
  end
end

DURATION = 3.days

def get_twitter_client
  client = Twitter::REST::Client.new do |config|
    config.consumer_key        = Rails.application.secrets.twitter_consumer_key
    config.consumer_secret     = Rails.application.secrets.twitter_consumer_secret
    config.access_token        = Rails.application.secrets.twitter_access_token
    config.access_token_secret = Rails.application.secrets.twitter_access_secret
  end
end

def get_hot_entry_tweet
  from     = DURATION.ago
  to       = from + DURATION
  @entries = Entry.hot_entries_within_period(from: from, to: to)

  if @entries.blank?
    puts "Not found hot entries."
    return
  end

  entry  = @entries[0]
  origin = JSON.load(entry.origin)

  if origin.present? && origin['title'].present?
    body  = "✏[話題の記事] #{entry.title} by #{origin['title']}"
    body  = (body.length > 116) ? body[0..115].to_s : body
    tweet = "#{body} #{entry.originId}"
  else
    puts "Not found origin of entry."
  end
end

def update(client, tweet)
  begin
    client.update(tweet.chomp)
    puts tweet
  rescue => e
    Rails.logger.error "<<twitter.rake::tweet.update ERROR : #{e.message}>>"
  end
end
