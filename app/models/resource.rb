class Resource < ApplicationRecord
  belongs_to :wall, class_name: Wall
  attr_accessor :stream

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

  def self.set_streams(items)
    hash = items.reduce({}) do |h, i|
      h[i.stream_type] = [] if h[i.stream_type].nil?
      h[i.stream_type].push i
      h
    end
    if hash[:journal].present?
      Journal.where(stream_id: hash[:journal].map {|i| i.stream_id }).each {|j|
        hash[:journal].select {|i| i.stream_id == j.stream_id }.each {|i| i.stream = j }
      }
    end
    if hash[:topic].present?
      Topic.where(id: hash[:topic].map {|i| i.stream_id }).each {|t|
        hash[:topic].select {|i| i.stream_id == t.id }.each {|i| i.stream = t }
      }
    end
    if hash[:feed].present?
      Feed.where(id: hash[:feed].map {|i| i.stream_id }).each {|f|
        hash[:feed].select {|i| i.stream_id == f.id }.each {|i| i.stream = f }
      }
    end
    if hash[:keyword].present?
      Keyword.where(id: hash[:keyword].map {|i| i.stream_id }).each {|k|
        hash[:keyword].select {|i| i.stream_id == k.id }.each {|i| i.stream = k }
      }
    end
    if hash[:tag].present?
      Tag.where(id: hash[:tag].map {|i| i.stream_id }).each {|t|
        hash[:tag].select {|i| i.stream_id == t.id }.each {|i| i.stream = t }
      }
    end
    if hash[:latest].present?
      hash[:latest].each do |i|
        i.stream = {
          id:    i.stream_id,
          label: 'latest',
        }
      end
    end
    if hash[:hot].present?
      hash[:hot].each do |i|
        i.stream = {
          id:    i.stream_id,
          label: 'hot',
        }
      end
    end
    if hash[:popular].present?
      hash[:popular].each do |i|
        i.stream = {
          id:    i.stream_id,
          label: 'popular',
        }
      end
    end
  end

  def stream_id
    resource_id
  end

  def stream_type
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
