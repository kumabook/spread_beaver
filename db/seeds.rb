require 'rest-client'

user = User.first_or_create(email: 'admin@example.com',
                             type: User.types[:admin],
                         password: 'admin',
                         password_confirmation: 'admin')

puts "Create admin user as id: #{user.id}"


app = Doorkeeper::Application.find_or_create_by name: "ios",
                                                redirect_uri: "urn:ietf:wg:oauth:2.0:oob"

puts "Create ios app id: #{app.id}"

client = Feedlr::Client.new

feedIds = [
  "feed/http://pitchfork.com/rss/news",
  "feed/http://pitchfork.com/rss/reviews/best/albums",
  "feed/http://pitchfork.com/rss/reviews/best/tracks",
]


Feed.find_or_create_with_ids(feedIds).each do |f|
  puts "Create feed(id: #{f.id})"
end

Entry.find_each do |entry|
  Entry.reset_counters(entry.id, :saved_entries)
  Entry.reset_counters(entry.id, :read_entries)
end
puts "Reset counter cache of entry.saved_count"
puts "Reset counter cache of entry.read_count"

Track.find_each do |track|
  Track.reset_counters(track.id, :likes)
  Track.reset_counters(track.id, :entries)
end
puts "Reset counter cache of track.likes_count"
