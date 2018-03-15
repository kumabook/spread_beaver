require 'pink_spider'
class Playlist < Enclosure
  def get_content
    PinkSpider.new.fetch_playlist(id)
  end

  def fetch_content
    @content = get_content
  end

  def title
    fetch_content if @content.nil?
    "#{@content["title"]} / #{@content["owner_name"]}"
  end

  def permalink_url provider, identifier
    fetch_content if @content.nil?
    @content["url"]
  end

  def is_active
    @content['velocity'] > 0
  end

  def activate
    self.class.update_content(id, { velocity: 10.0 })
  end

  def deactivate
    self.class.update_content(id, { velocity: 0.0 })
  end
end
