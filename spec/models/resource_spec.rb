# coding: utf-8
require 'rails_helper'

describe Resource do
  let (:user) { FactoryBot.create(:default) }
  let (:wall) { Wall.create!(label: "ios/news", description: "news") }

  describe "#item_type" do
    it { expect(res("journal/ハイライト").item_type).to eq(:journal) }
    it { expect(res("topic/ブログ").item_type).to eq(:topic) }
    it { expect(res("feed/http://www.rss.co.jp/feed/").item_type).to eq(:feed) }
    it { expect(res("keyword/rock").item_type).to eq(:keyword) }
    it { expect(res("user/#{user.id}/tag/rock").item_type).to eq(:tag) }
    it { expect(res("user/#{user.id}/category/rock").item_type).to eq(:category) }
    it { expect(res("tag/global.latest").item_type).to eq(:global_tag) }
    it { expect(res("tag/global.hot").item_type).to eq(:global_tag) }
    it { expect(res("tag/global.popular").item_type).to eq(:global_tag) }
    it { expect(res("tag/global.featured").item_type).to eq(:global_tag) }
  end

  describe "#global_tag_label" do
    it { expect(res("tag/global.latest").global_tag_label).to eq("latest") }
    it { expect(res("tag/global.hot").global_tag_label).to eq("hot") }
    it { expect(res("tag/global.popular").global_tag_label).to eq("popular") }
    it { expect(res("tag/global.featured").global_tag_label).to eq("featured") }
  end

  describe "::set_item_of_stream_resources" do
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
      res("tag/global.featured")
      resources = Wall.find(wall.id).resources
      Resource::set_item_of_stream_resources(resources)
    end
    it do
      resources.each do |r|
        expect(r.item).not_to be_nil
        expect(r.item_type).not_to be_nil
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
