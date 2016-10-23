# coding: utf-8
require 'rails_helper'

describe Feed do
  let!  (:feed) { FactoryGirl.create(:feed) }
  describe "Feed#delete_cache_of_search_results" do
    context "when feeds are created" do
      it {
        expect(Feed).to receive(:delete_cache_of_search_results)
        FactoryGirl.create(:feed)
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
end
