# coding: utf-8
require 'rails_helper'

describe Resource do
  let (:user) { FactoryGirl.create(:default) }
  let (:wall) { Wall.create!(label: "ios/news", description: "news") }

  describe "#stream_type" do
    it { expect(res("journal/ハイライト").stream_type).to eq(:journal) }
    it { expect(res("topic/ブログ").stream_type).to eq(:topic) }
    it { expect(res("feed/http://www.rss.co.jp/feed/").stream_type).to eq(:feed) }
    it { expect(res("keyword/rock").stream_type).to eq(:keyword) }
    it { expect(res("user/#{user.id}/tag/rock").stream_type).to eq(:tag) }
    it { expect(res("user/#{user.id}/category/rock").stream_type).to eq(:category) }
    it { expect(res("tag/global.latest").stream_type).to eq(:latest) }
    it { expect(res("tag/global.hot").stream_type).to eq(:hot) }
    it { expect(res("tag/global.popular").stream_type).to eq(:popular) }
  end

  describe "::set_streams" do
    resources = []
    before do
      Journal.create!(label: "ハイライト")
      Topic.create!(label: "ブログ")
      Feed.create!(id: "feed/http://www.rss.co.jp/feed/")
      Keyword.create!(label: "rock")
      Tag.create!(label: "rock", user: user)
      Category.create!(label: "rock", user: user)

      res("journal/ハイライト")
      res("topic/ブログ")
      res("feed/http://www.rss.co.jp/feed/")
      res("keyword/rock")
      res("user/#{user.id}/tag/rock")
      res("tag/global.latest")
      res("tag/global.hot")
      res("tag/global.popular")
      resources = Wall.find(wall.id).resources
      Resource::set_streams(resources)
    end
    it do
      resources.each do |r|
        expect(r.stream).not_to be_nil
      end
    end
  end

  def res(resource_id)
    Resource::create!(resource_id:   resource_id,
                      resource_type: "stream",
                      engagement:    0,
                      wall_id:       wall.id)
  end
end
