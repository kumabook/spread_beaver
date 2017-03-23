require 'pink_spider'
class Track < Enclosure
  def permalink_url provider, identifier
    fetch_content if @content.nil?
    @content["url"]
  end
end
