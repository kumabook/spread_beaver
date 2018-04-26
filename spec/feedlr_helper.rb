# frozen_string_literal: true

require "securerandom"

class FeedlrHelper
  def self.cursor
    Hashie::Mash.new(
      items: [entry(SecureRandom.uuid)]
    )
  end

  def self.feed(id)
    Hashie::Mash.new(
      id:     id,
      title: "title",
      description: "",
      website:     "",
      visualUrl:   "",
      coverUrl:    "",
      iconUrl:     "",
      language:    "",
      partial:     "",
      coverColor:  "",
      contentType: "",
      subscribers: 10,
      velocity:    10
    )
  end

  def self.entry(id)
    alternate         = Feedlr::Base.new()
    alternate.href     = "http://test.com/1"
    alternate.type     ="text/html"

    content            = Feedlr::Base.new()
    content.content    = "content"
    content.direction  = "ltr"
    origin             = Feedlr::Base.new()
    origin.htmlUrl     = "http://test.com"
    origin.streamId    = "feed/http://test.com/rss"
    origin.title       = "feed"
    visual             = Feedlr::Base.new()
    visual.contentType ="image/jpeg"
    visual.height      = 504
    visual.width       = 500
    visual.processor   = "feedly-nikon-v3.1"
    visual.url         = "http://test.com/1/img.jpg"

    entry                = Feedlr::Base.new()
    entry.alternate      = [alternate]
    entry.content        = content
    entry.crawled        = 1_458_303_643_798
    entry.engagement     = 143
    entry.engagementRate = 11.0
    entry.fingerprint    = "38c6513d"
    entry.id             = id
    entry.origin         =  origin
    entry.originId       = "http://test.com/1"
    entry.published      = 1_458_303_643_798
    entry.title          = "title"
    entry.unread         = true
    entry.visual         = visual
    entry
  end
end
