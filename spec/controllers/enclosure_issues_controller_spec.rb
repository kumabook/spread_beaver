# frozen_string_literal: true
require "rails_helper"

describe EnclosureIssuesController, type: :controller do
  let! (:journal    ) {     Journal.create!(label: "journal", description: "desc") }
  let! (:issue      ) {       Issue.create!(label: "issue"  , description: "desc", journal_id: journal.id) }
  let! (:track      ) { FactoryBot.create (:track                               ) }
  let  (:user       ) { FactoryBot.create (:admin                               ) }
  let  (:track_issue) { EnclosureIssue.create!(enclosure_id:   track.id,
                                               enclosure_type: Track.name,
                                               issue_id: issue.id)
  }

  before(:each) do
    login_user user
  end

  describe "GET new" do
    before { get :new, params: { issue_id: issue.id, enclosure_type: Track.name } }
    it { expect(response).to render_template("new") }
  end

  describe "POST create" do
    before do
      post :create, params: {
             enclosure_issue: {
               issue_id:       issue.id,
               enclosure_id:   track.id,
               enclosure_type: Track.name,
               engagement:     100
             }
           }
    end
    it { expect(response).to redirect_to issue_tracks_url(issue) }
    it { expect(EnclosureIssue.find_by(enclosure_id: track.id, issue_id: issue.id)).not_to be_nil }
  end

  describe "GET edit" do
    before do
      get :edit, params: { id: track_issue.id, issue_id: issue.id }
    end
    it { expect(response).to render_template("edit") }
  end

  describe "POST update" do
    before do
      post :update, params: {
        id: track_issue.id,
        issue_id: issue.id,
        enclosure_issue: {
          enclosure_type: Track.name,
          engagement:     200
        }
      }
    end
    it { expect(response).to redirect_to issue_tracks_url(issue) }
    it { expect(EnclosureIssue.find(track_issue.id).engagement).to eq(200) }
  end
end
