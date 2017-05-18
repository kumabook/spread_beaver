class Resource < ApplicationRecord
  belongs_to :wall, class_name: Wall
  attr_accessor :item

  enum resource_type: {
         stream:          0,
         track_stream:    1,
         album_stream:    2,
         playlist_stream: 3,
         entry:           4,
         track:           5,
         album:           6,
         playlist:        7,
         custom:          8
       }

  def as_json(options = {})
    h = super(options)
    h["item_type"] = self.item_type
    h["item"]      = self.item
    h
  end

  def item_type
    item_type
  end

  def self.set_item_of_stream_resources(resources)
    hash = resources.reduce({}) do |h, i|
      h[i.item_type] = [] if h[i.item_type].nil?
      h[i.item_type].push i
      h
    end
    [{ clazz: Journal , type: :journal },
     { clazz: Topic   , type: :topic },
     { clazz: Feed    , type: :feed },
     { clazz: Keyword , type: :keyword },
     { clazz: Tag     , type: :tag },
     { clazz: Category, type: :category }].each do |h|
      type = h[:type]
      clazz = h[:clazz]
      if hash[type].present?
        clazz.stream_id(hash[type].map {|r| r.stream_id }).each do |v|
          hash[type].select {|r| r.stream_id == v.stream_id }.each do |r|
            r.item = v
          end
        end
      end
    end
    [:latest, :hot, :popular].each do |name|
      if hash[name].present?
        hash[name].each do |r|
          r.item = {
            id:    r.stream_id,
            label: name.to_s,
          }
        end
      end
    end
  end

  def stream_id
    resource_id
  end

  def item_type
    case resource_id
    when /journal\/.*/
      return :journal
    when /topic\/.*/
      return :topic
    when /feed\/.*/
      return :feed
    when /keyword\/.*/
      return :keyword
    when /user\/.*\/tag\/.*/
      return :tag
    when /user\/.*\/category\/.*/
      return :category
    when /tag\/global\.latest/
      return :latest
    when /tag\/global\.hot/
      return :hot
    when /tag\/global\.popular/
      return :popular
    end
  end
end
