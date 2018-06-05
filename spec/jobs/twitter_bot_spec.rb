# frozen_string_literal: true

require "rails_helper"

describe "TwitterBot" do
  let!(:user) { FactoryBot.create(:admin) }
  let!(:mix_topic) { FactoryBot.create(:mix) }
  let(:setting) {
    {
      email:  user.email,
      locale: "ja",
      topic:  mix_topic.id
    }.with_indifferent_access
  }

  let(:auth) {
    {
      user_id:     user.id,
      provider:    "twitter",
      uid:         "typica_jp",
      credentials: JSON.generate({ token: "token", secret: "secret" }),
      raw_info:    "{}",
    }
  }
  before(:each) do
    mock_up_pink_spider
    allow_any_instance_of(Twitter::REST::Client).to receive(:update) { [] }
    Authentication.create! auth
  end

  describe "chart_track" do
    it do
      options  = { index: 0 }.with_indifferent_access
      tweets = TwitterBot.perform_now("chart_track", setting, options)
      expect(tweets.count).to be > 0
    end
  end

  describe "weekly_hot_track" do
    before(:each) do
      PlayedEnclosure.create!(enclosure:      Track.first,
                              enclosure_type: Track.name,
                              user:           user,
                              created_at:     1.day.ago,
                              updated_at:     1.day.ago)
    end
    it do
      tweets = TwitterBot.perform_now("weekly_hot_track", setting)
      expect(tweets.count).to be > 0
    end
  end

  describe "weekly_hot_entries" do
    before(:each) do
      ReadEntry.create!(entry:      Entry.first,
                        user:       user,
                        created_at: 1.day.ago,
                        updated_at: 1.day.ago)
    end
    it do
      tweets = TwitterBot.perform_now("weekly_hot_entry", setting)
      expect(tweets.count).to be > 0
    end
  end
end
