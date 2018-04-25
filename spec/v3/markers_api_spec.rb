# frozen_string_literal: true
require "rails_helper"

RSpec.describe "Markers api", type: :request, autodoc: true do
  ENTRY_NUM     = 4
  ENCLOSURE_NUM = 4
  MARKED_NUM    = 2
  let (:feed   ) { Feed.create!(id: "feed/http://test.com/rss" , title: "feed") }
  let (:entries) {
    ENTRY_NUM.times.map { FactoryBot.create(:normal_entry, feed: feed) }
  }
  let (:tracks) {
    TRACK_PER_ENTRY.times.map { FactoryBot.create(:track) }
  }
  context "after login" do
    before do
      setup()
      login()
    end

    context "markAsRead" do
      it "marks entries as read" do
        count = Entry.read(@user).count
        post "/v3/markers",
             params: {
               type: "entries",
               action: "markAsRead",
               entryIds: [entries[MARKED_NUM + 1].id]
             },
             headers: headers_for_login_user
        expect(@response.status).to eq(200)
        after_count = Entry.read(@user).count
        expect(after_count).to eq(count + 1)
      end
    end
    context "markAsUnread" do
      before do
        entries[0...MARKED_NUM].each { |entry|
          ReadEntry.create! user: @user,
                            entry: entry
        }
      end
      it "keeps entries unread" do
        count = Entry.read(@user).count
        post "/v3/markers",
             params: {
               type: "entries",
               action: "keepUnread",
               entryIds: [entries[0].id]
             },
             headers: headers_for_login_user
        expect(@response.status).to eq(200)
        after_count = Entry.read(@user).count
        expect(after_count).to eq(count - 1)
      end
    end

    context "markAsSaved" do
      it "marks entries as saved" do
        count = Entry.saved(@user).count
        post "/v3/markers",
             params: {
               type: "entries",
               action: "markAsSaved",
               entryIds: [entries[MARKED_NUM + 1].id]
             },
             headers: headers_for_login_user
        expect(@response.status).to eq(200)
        after_count = Entry.saved(@user).count
        expect(after_count).to eq(count + 1)
      end
    end
    context "markAsUnsaved" do
      before do
        entries[0...MARKED_NUM].each { |entry|
          SavedEntry.create! user: @user,
                             entry: entry
        }
      end
      it "marks entries as unsaved" do
        count = Entry.saved(@user).count
        post "/v3/markers",
             params: {
               type: "entries",
               action: "markAsUnsaved",
               entryIds: [entries[0].id]
             },
             headers: headers_for_login_user
        expect(@response.status).to eq(200)
        after_count = Entry.saved(@user).count
        expect(after_count).to eq(count - 1)
      end
    end

    context "markAsLiked" do
      before do
        entries[0].tracks = tracks
      end
      it "marks tracks as liked" do
        count = Track.liked(@user).count
        post "/v3/markers",
             params: {
               type: "tracks",
               action: "markAsLiked",
               trackIds: [entries[0].tracks[MARKED_NUM + 1].id]
             },
             headers: headers_for_login_user
        expect(@response.status).to eq(200)
        after_count = Track.liked(@user).count
        expect(after_count).to eq(count + 1)
      end
    end
    context "markAsUnliked" do
      before do
        entries[0].tracks = tracks
        entries[0].tracks[0...MARKED_NUM].each { |track|
          LikedEnclosure.create!(user:           @user,
                                 enclosure:      track,
                                 enclosure_type: Track.name)
        }
      end
      it "marks tracks as unliked" do
        count = Track.liked(@user).count
        post "/v3/markers",
             params: {
               type: "tracks",
               action: "markAsUnliked",
               trackIds: [entries[0].tracks[0].id]
             },
             headers: headers_for_login_user
        expect(@response.status).to eq(200)
        after_count = Track.liked(@user).count
        expect(after_count).to eq(count - 1)
      end
    end

    context "tracks markAsSaved" do
      before do
        entries[0].tracks = tracks
      end
      it "marks tracks as saved" do
        count = Track.joins(:saved_users).where(users: { id: @user.id }).count
        post "/v3/markers",
             params: {
               type: "tracks",
               action: "markAsSaved",
               trackIds: [entries[0].tracks[MARKED_NUM + 1].id]
             },
             headers: headers_for_login_user
        expect(@response.status).to eq(200)
        after_count = Track.joins(:saved_users).where(users: { id: @user.id }).count
        expect(after_count).to eq(count + 1)
      end
    end
    context "markAsUnsaved" do
      before do
        entries[0].tracks = tracks
        entries[0].tracks[0...MARKED_NUM].each { |track|
          SavedEnclosure.create!(user:           @user,
                                 enclosure:      track,
                                 enclosure_type: Track.name)
        }
      end
      it "marks tracks as unsaved" do
        count = Track.saved(@user).count
        post "/v3/markers",
             params: {
               type: "tracks",
               action: "markAsUnsaved",
               trackIds: [entries[0].tracks[0].id]
             },
             headers: headers_for_login_user
        expect(@response.status).to eq(200)
        after_count = Track.saved(@user).count
        expect(after_count).to eq(count - 1)
      end
    end

    context "markAsPlayed" do
      before do
        entries[0].tracks = tracks
      end
      context "first play" do
        it "marks tracks as played" do
          count = Track.played(@user).count
          post "/v3/markers",
               params: {
                 type: "tracks",
                 action: "markAsPlayed",
                 trackIds: [entries[0].tracks[0].id]
               },
               headers: headers_for_login_user
          expect(@response.status).to eq(200)
          after_count = Track.played(@user).count
          expect(after_count).to eq(count + 1)
        end
      end
      context "recent play" do
        before do
          entries[0].tracks[0...MARKED_NUM].each { |track|
            PlayedEnclosure.create!(user:           @user,
                                    enclosure:      track,
                                    enclosure_type: Track.name)
          }
        end
        it "marks tracks as played" do
          count = Track.played(@user).count
          post "/v3/markers",
               params: {
                 type: "tracks",
                 action: "markAsPlayed",
                 trackIds: [entries[0].tracks[0].id]
               },
               headers: headers_for_login_user
          expect(@response.status).to eq(200)
          after_count = Track.played(@user).count
          expect(after_count).to eq(count)
        end
      end
      context "old play" do
        before do
          entries[0].tracks[0...MARKED_NUM].each { |track|
            PlayedEnclosure.create!(user:           @user,
                                    enclosure:      track,
                                    enclosure_type: Track.name,
                                    created_at:     1.day.ago,
                                    updated_at:     1.day.ago)
          }
        end
        it "marks tracks as played" do
          count = Track.played(@user).count
          post "/v3/markers",
               params: {
                 type: "tracks",
                 action: "markAsPlayed",
                 trackIds: [entries[0].tracks[0].id]
               },
               headers: headers_for_login_user
          expect(@response.status).to eq(200)
          after_count = Track.played(@user).count
          expect(after_count).to eq(count + 1)
        end
      end
    end
    context "ignore empty string" do
      it "marks tracks as played" do
        count = Track.played(@user).count
        post "/v3/markers",
             params: {
               type: "tracks",
               action: "markAsPlayed",
               trackIds: [""]
             },
             headers: headers_for_login_user
        expect(@response.status).to eq(200)
        after_count = Track.played(@user).count
        expect(after_count).to eq(count)
      end
    end
  end
end
