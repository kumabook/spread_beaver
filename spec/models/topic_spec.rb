# coding: utf-8
# frozen_string_literal: true
require "rails_helper"

describe Topic do
  let!  (:feed) { FactoryBot.create(:feed) }
  let! (:topic) { Topic.create!(label: "topic", description: "desc", feeds: [feed]) }

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

  describe "Topic#delete_cache_of_stream" do
    context "when feed of topic is created" do
      it {
        expect(Topic).to receive(:delete_cache_of_stream)
        expect(Topic).to receive(:delete_cache_of_mix)
        topic.feeds << FactoryBot.create(:feed)
      }
    end

    context "when feed of topic is destroyed" do
      it {
        expect(Topic).to receive(:delete_cache_of_stream)
        expect(Topic).to receive(:delete_cache_of_mix)
        topic.feeds[0].destroy
      }
    end

    context "when entries of topic is destroyed" do
      it {
        expect(Topic).to receive(:delete_cache_of_stream)
        expect(Topic).to receive(:delete_cache_of_mix)
        topic.feeds[0].entries[0].destroy!
      }
    end

    context "when entries of topic is created" do
      it {
        expect(Topic).to receive(:delete_cache_of_stream)
        expect(Topic).to receive(:delete_cache_of_mix)
        topic.feeds[0].entries << FactoryBot.create(:entry)
      }
    end
  end
end
