require 'rest-client'

admin = User.find_or_create_by(email: 'admin@example.com', type: Admin.name) do |user|
  user.password              = 'admin'
  user.password_confirmation = 'admin'
  user.save!
end
puts "Create admin user as id: #{admin.id}"
test_user = User.find_or_create_by(email: 'test_member@example.com', type: Member.name) do |user|
  user.password              = 'test_memeber'
  user.password_confirmation = 'test_memeber'
  user.save!
end
puts "Create test member as id: #{test_user.id}"

app = Doorkeeper::Application.find_or_create_by name: "ios",
                                                redirect_uri: "urn:ietf:wg:oauth:2.0:oob"

puts "Create ios app id: #{app.id}"

Journal.where(label: 'highlight').first_or_create
puts "Create default journal hightlight"

news_topic = Topic.first_or_create(label: 'news')

feedIds = [
  "feed/http://pitchfork.com/rss/news",
  "feed/http://pitchfork.com/rss/reviews/best/albums",
  "feed/http://pitchfork.com/rss/reviews/best/tracks",
  'feed/http://spincoaster.com/feed'
]

Feed.find_or_create_with_ids(feedIds).each do |f|
  puts "Create feed(id: #{f.id})"
  f.topics = [news_topic]
end

Entry.find_each do |entry|
  Entry.reset_counters(entry.id, :saved_entries)
  Entry.reset_counters(entry.id, :read_entries)
end
puts "Reset counter cache of entry.saved_count"
puts "Reset counter cache of entry.read_count"

Track.find_each do |track|
  Track.reset_counters(track.id, :liked_enclosures)
  Track.reset_counters(track.id, :entries)
end
puts "Reset counter cache of track.likes_count"
puts "Reset counter cache of track.entries_count"
