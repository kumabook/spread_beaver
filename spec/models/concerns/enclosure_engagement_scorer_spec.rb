# frozen_string_literal: true
require 'rails_helper'

describe EnclosureEngagementScorer do
  let (:track) { FactoryBot.create(:track) }
  let (:playlist) { FactoryBot.create(:playlist) }
  let (:today) { Time.now.beginning_of_day }
  let (:week_ago) { today - 7.days }

  let (:japan) { Topic.create!(label: "japan") }
  let (:global) { Topic.create!(label: "global") }

  pick_score = EnclosureEngagementScorer::SCORES_PER_MARK['picks']

  def create_pick(time)
    Pick.create!(enclosure_id:   track.id,
                 enclosure_type: Track.name,
                 container_id:   playlist.id,
                 container_type: Playlist.name,
                 created_at:     time,
                 updated_at:     time)
  end

  describe "::most_engaging_items" do
    it "should return full score for track picked now" do
      create_pick(today)
      query  = Mix::Query.new(week_ago..today)
      tracks = Track.most_engaging_items(query: query)
      expect(tracks[0].engagement).to eq pick_score
    end

    it "should return full score for track picked the today" do
      create_pick(today - 5.hours)
      query  = Mix::Query.new(week_ago..today)
      tracks = Track.most_engaging_items(query: query)
      expect(tracks[0].engagement).to eq pick_score
    end

    it "should return full score for track picked yesterday" do
      create_pick(today - 24.hours)
      query  = Mix::Query.new(week_ago..today)
      tracks = Track.most_engaging_items(query: query)
      expect(tracks[0].engagement).to be_within(0.0001).of(pick_score * 13.0 / 14.0)
    end

    context "with topic" do
      before do
        japan_mix_journal = Journal.create_topic_mix_journal(japan)
        global_mix_journal = Journal.create_topic_mix_journal(global)
        issue = japan.find_or_create_mix_issue(japan_mix_journal)
        issue.playlists << playlist
        create_pick(today)
      end
      it "should return score with specified topic" do
        query  = Mix::Query.new(week_ago..today)

        tracks = Track.most_engaging_items(stream: japan, query: query)
        expect(tracks[0].engagement).to eq pick_score

        tracks = Track.most_engaging_items(stream: global, query: query)
        expect(tracks[0].engagement).to eq 0
      end
    end
  end
end
