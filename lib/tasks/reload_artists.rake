# frorzen_string_literal: true

require "pink_spider"

task reload_artists: :environment do
  batch_size = 2000
  pink_spider = PinkSpider.new
  count = Artist.count
  i = 0
  Artist.find_each(batch_size: batch_size) do |artist|
    puts "[#{i}/#{count}]#{artist.name} is reloading"
    content = pink_spider.fetch_artist(artist.id)
    artist.update_by_content(content)
    artist.save!
    i += 1
  end
end
