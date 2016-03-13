require 'rails_helper'

RSpec.describe "Likes api", type: :request, autodoc: true do
  MARKED_NUM = 2
  context 'after login' do
    before(:all) do
      setup()
      login()
      @feed = FactoryGirl.create(:feed)
      @feed.entries[0].tracks[0...MARKED_NUM].each { |track|
        Like.create! user: @user,
                     track: track
      }
      @feed.entries[0...MARKED_NUM].each { |entry|
        UserEntry.create! user: @user,
                          entry: entry
      }
    end

    it "marks entries as saved" do
      count = Entry.joins(:users).where(users: { id: @user.id }).count
      post "/v3/markers",
           {
             type: 'entries',
             action: 'markAsSaved',
             entryIds: [@feed.entries[MARKED_NUM + 1].id]
           },
           Authorization: "Bearer #{@token['access_token']}"
      expect(@response.status).to eq(200)
      after_count = Entry.joins(:users).where(users: { id: @user.id }).count
      expect(after_count).to eq(count + 1)
    end

    it "marks entries as unsaved" do
      count = Entry.joins(:users).where(users: { id: @user.id }).count
      post "/v3/markers",
           {
             type: 'entries',
             action: 'markAsUnsaved',
             entryIds: [@feed.entries[0].id]
           },
           Authorization: "Bearer #{@token['access_token']}"
      expect(@response.status).to eq(200)
      after_count = Entry.joins(:users).where(users: { id: @user.id }).count
      expect(after_count).to eq(count - 1)
    end

    it "marks tracks as liked" do
      count = Track.joins(:users).where(users: { id: @user.id }).count
      post "/v3/markers",
           {
             type: 'tracks',
             action: 'markAsLiked',
             trackIds: [@feed.entries[0].tracks[MARKED_NUM + 1].id]
           },
           Authorization: "Bearer #{@token['access_token']}"
      expect(@response.status).to eq(200)
      after_count = Track.joins(:users).where(users: { id: @user.id }).count
      expect(after_count).to eq(count + 1)
    end

    it "marks tracks as unliked" do
      count = Track.joins(:users).where(users: { id: @user.id }).count
      post "/v3/markers",
           {
             type: 'tracks',
             action: 'markAsUnliked',
             trackIds: [@feed.entries[0].tracks[0].id]
           },
           Authorization: "Bearer #{@token['access_token']}"
      expect(@response.status).to eq(200)
      after_count = Track.joins(:users).where(users: { id: @user.id }).count
      expect(after_count).to eq(count - 1)
    end
  end
end
