# frozen_string_literal: true

require "rest-client"

admin = User.find_or_create_by(email: "admin@example.com", type: Admin.name) do |user|
  user.password              = "admin"
  user.password_confirmation = "admin"
  user.save!
end
puts "Create admin user as id: #{admin.id}"
test_user = User.find_or_create_by(email: "test_member@example.com", type: Member.name) do |user|
  user.password              = "test_memeber"
  user.password_confirmation = "test_memeber"
  user.save!
end
puts "Create test member as id: #{test_user.id}"

app = Doorkeeper::Application.find_or_create_by name: "ios",
                                                redirect_uri: "urn:ietf:wg:oauth:2.0:oob"

puts "Create ios app id: #{app.id}"

Journal.where(label: "highlight").first_or_create
puts "Create default journal hightlight"

news_topic = Topic.first_or_create(label: "news")

feed_urls = [
  "http://pitchfork.com/rss/news",
  "http://pitchfork.com/rss/reviews/best/albums",
  "http://pitchfork.com/rss/reviews/best/tracks",
  "http://spincoaster.com/feed"
]

feeds = feed_urls.map do |url|
  puts "Creating #{url}"
  f = Feed.find_or_create_by_url(url)
  puts "Created #{f.id}"
  f
end

news_topic.feeds = feeds
