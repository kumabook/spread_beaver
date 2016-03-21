# coding: utf-8
require 'rails_helper'

describe Entry do
  it "is created by feeldr entry" do

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
    entry.alternate      = alternate
    entry.content        = content
    entry.crawled        = 1458303643798
    entry.engagement     = 143
    entry.engagementRate = 11.0
    entry.fingerprint    = "38c6513d"
    entry.id             = "12345"
    entry.keywords       = ["SERIES"]
    entry.origin         =  origin
    entry.originId       = "http://test.com/1"
    entry.published      = 1458303643798
    entry.title          = "title"
    entry.unread         = true
    entry.visual         = visual

    f = Feed.first_or_create(id: 'feed/http://test.com/rss')
    e = Entry.first_or_create_by_feedlr(entry, f)
    expect(e).not_to be_nil()
    expect(e.published).not_to be_nil()
    expect(e.crawled).not_to be_nil()
  end
end
