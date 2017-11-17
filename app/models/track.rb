require 'pink_spider'
class Track < Enclosure
  def permalink_url
    fetch_content if @content.nil?
    case @content["provider"]
    when 'Spotify'
      s = @content["url"].split(':')
      "http://open.spotify.com/#{s[1]}/#{s[2]}"
    else
      @content["url"]
    end
  end
end
