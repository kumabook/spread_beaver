require 'rails_helper'

describe EnclosureEngagementScorer do
  let (:track) { FactoryBot.create(:track) }
  let (:playlist) { FactoryBot.create(:playlist) }
  let (:today) { Time.now.beginning_of_day }
  let (:week_ago) { today - 7.days }
  before do
    pick = Pick.create!(enclosure_id:   track.id,
                        enclosure_type: Track.name,
                        container_id:   playlist.id,
                        container_type: Playlist.name,
                        created_at:     today,
                        updated_at:     today)
  end

  describe "::most_engaging_items" do
    it "should return full score for track picked now" do
      pick_score = EnclosureEngagementScorer::SCORES_PER_MARK['picks']
      query  = Mix::Query.new(week_ago..today)
      tracks = Track.most_engaging_items(query: query)
      expect(tracks[0].engagement).to eq pick_score
    end
  end
end
