# coding: utf-8
require 'rails_helper'

describe Topic do
  let!  (:feed) { FactoryGirl.create(:feed) }
  let! (:topic) { Topic.create!(label: "topic", description: "desc", feeds: [feed])}

  describe "Topic#delete_cache_entries" do
    context "when topic is deleted" do
      feedsCount = 0
      before do
        feedsCount = Feed.all.count
        topic.destroy!
      end
      it { expect(Feed.all.count).to eq(feedsCount) }
    end
  end

  describe "Topic#delete_cache" do
    context "when topic is created" do
      it {
        expect(Topic).to receive(:delete_cache)
        Topic.create!(label: "new_topic", description: "desc")
      }
    end

    context "when topic is updated" do
      it {
        expect(Topic).to receive(:delete_cache)
        topic.update!(label: "new title")
      }
    end

    context "when topic is destroyed" do
      it {
        expect(Topic).to receive(:delete_cache)
        topic.destroy!
      }
    end
  end

  context "when feed of topic is created" do
    it {
      expect(Entry).to receive(:delete_cache_of_stream)
      topic.feeds << FactoryGirl.create(:feed)
    }
  end

  context "when feed of topic is destroyed" do
    it {
      expect(Entry).to receive(:delete_cache_of_stream)
      topic.feeds[0].destroy
    }
  end

  context "when entries of topic is updated" do
    it {
      expect(Entry).to receive(:delete_cache_of_stream)
      topic.feeds[0].entries[0].destroy!
    }
  end

  context "when entries of topic is updated" do
    it {
      expect(Entry).to receive(:delete_cache_of_stream)
      topic.feeds[0].entries << FactoryGirl.create(:entry)
    }
  end
end