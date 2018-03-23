require 'pink_spider'
class Album < Enclosure
  def get_content
    PinkSpider.new.fetch_album(id)
  end

  def fetch_content
    @content = get_content
  end

  def title
    fetch_content if @content.nil?
    "#{@content["title"]} / #{@content["owner_name"]}"
  end

  def permalink_url
    fetch_content if @content.nil?
    case @content["provider"]
    when 'Spotify'
      s = @content["url"].split(':')
      "http://open.spotify.com/album/#{s[2]}"
    else
      @content["url"]
    end
  end
end
