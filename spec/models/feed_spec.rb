# coding: utf-8
require 'rails_helper'

describe Feed do
  let!  (:feed) { FactoryBot.create(:feed) }
  describe "Feed#delete_cache_of_search_results" do
    context "when feeds are created" do
      it {
        expect(Feed).to receive(:delete_cache_of_search_results)
        FactoryBot.create(:feed)
      }
    end
    context "when feeds are updated" do
      it {
        expect(feed).to receive(:delete_cache_of_search_results)
        feed.update!(title: "new title")
      }
    end
    context "when feeds are destroyed" do
      it {
        expect(feed).to receive(:delete_cache_of_search_results)
        feed.destroy!
      }
    end
  end

  describe "Feed#delete_cache_of_stream" do
    context "when entries of feed is destroyed" do
      it {
        expect(Feed).to receive(:delete_cache_of_stream)
        feed.entries[0].destroy!
      }
    end

    context "when entries of topic is created" do
      it {
        expect(Feed).to receive(:delete_cache_of_stream)
        feed.entries << Entry.create(id: "xxxxx",
                                     title: "entry",
                                     unread: 0,
                                     fingerprint: "",
                                     originId: "",
                                     feed_id: feed.id)
      }
    end
  end
end
