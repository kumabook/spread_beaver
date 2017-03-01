require 'rails_helper'

RSpec.describe "Markers api", type: :request, autodoc: true do
  MARKED_NUM = 2
  context 'after login' do
    before(:all) do
      setup()
      login()
      @feed = FactoryGirl.create(:feed)
      @feed.entries[0].tracks[0...MARKED_NUM].each { |track|
        TrackLike.create! user: @user,
                          track: track
      }
      @feed.entries[0...MARKED_NUM].each { |entry|
        SavedEntry.create! user: @user,
                           entry: entry
      }
      @feed.entries[0...MARKED_NUM].each { |entry|
        ReadEntry.create! user: @user,
                          entry: entry
      }
    end

    it "marks entries as read" do
      count = Entry.read(@user).count
      post "/v3/markers",
           params: {
             type: 'entries',
             action: 'markAsRead',
             entryIds: [@feed.entries[MARKED_NUM + 1].id]
           },
           headers: headers_for_login_user
      expect(@response.status).to eq(200)
      after_count = Entry.read(@user).count
      expect(after_count).to eq(count + 1)
    end

    it "keeps entries unread" do
      count = Entry.read(@user).count
      post "/v3/markers",
           params: {
             type: 'entries',
             action: 'keepUnread',
             entryIds: [@feed.entries[0].id]
           },
           headers: headers_for_login_user
      expect(@response.status).to eq(200)
      after_count = Entry.read(@user).count
      expect(after_count).to eq(count - 1)
    end

    it "marks entries as saved" do
      count = Entry.saved(@user).count
      post "/v3/markers",
           params: {
             type: 'entries',
             action: 'markAsSaved',
             entryIds: [@feed.entries[MARKED_NUM + 1].id]
           },
           headers: headers_for_login_user
      expect(@response.status).to eq(200)
      after_count = Entry.saved(@user).count
      expect(after_count).to eq(count + 1)
    end

    it "marks entries as unsaved" do
      count = Entry.saved(@user).count
      post "/v3/markers",
           params: {
             type: 'entries',
             action: 'markAsUnsaved',
             entryIds: [@feed.entries[0].id]
           },
           headers: headers_for_login_user
      expect(@response.status).to eq(200)
      after_count = Entry.saved(@user).count
      expect(after_count).to eq(count - 1)
    end

    it "marks tracks as liked" do
      count = Track.joins(:users).where(users: { id: @user.id }).count
      post "/v3/markers",
           params: {
             type: 'tracks',
             action: 'markAsLiked',
             trackIds: [@feed.entries[0].tracks[MARKED_NUM + 1].id]
           },
           headers: headers_for_login_user
      expect(@response.status).to eq(200)
      after_count = Track.joins(:users).where(users: { id: @user.id }).count
      expect(after_count).to eq(count + 1)
    end

    it "marks tracks as unliked" do
      count = Track.joins(:users).where(users: { id: @user.id }).count
      post "/v3/markers",
           params: {
             type: 'tracks',
             action: 'markAsUnliked',
             trackIds: [@feed.entries[0].tracks[0].id]
           },
           headers: headers_for_login_user
      expect(@response.status).to eq(200)
      after_count = Track.joins(:users).where(users: { id: @user.id }).count
      expect(after_count).to eq(count - 1)
    end
  end
end
