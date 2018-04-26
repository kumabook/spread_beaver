# frozen_string_literal: true
require "rails_helper"

describe EntryIssuesController, type: :controller do
  let! (:journal) {     Journal.create!(label: "journal", description: "desc") }
  let! (:issue) {       Issue.create!(label: "issue"  , description: "desc", journal_id: journal.id) }
  let! (:entry) { FactoryBot.create :entry }
  let  (:user) { FactoryBot.create :admin }
  let  (:entry_issue) { EntryIssue.create!(entry_id: entry.id, issue_id: issue.id) }

  before(:each) do
    login_user user
  end

  describe "GET new" do
    before { get :new, params: { issue_id: issue.id, entry_id: entry.id } }
    it { expect(response).to render_template("new") }
  end

  describe "POST create" do
    before do
      post :create, params: {
             entry_issue: {
               issue_id: issue.id,
               entry_id: entry.id,
               engagement: 100
             }
           }
    end
    it { expect(response).to redirect_to issue_entries_url(issue) }
    it { expect(EntryIssue.find_by(entry_id: entry.id, issue_id: issue.id)).not_to be_nil }
  end

  describe "GET edit" do
    before do
      get :edit, params: { id: entry_issue.id, issue_id: issue.id }
    end
    it { expect(response).to render_template("edit") }
  end

  describe "POST update" do
    before do
      post :update, params: {
        id: entry_issue.id,
        issue_id: issue.id,
        entry_issue: {
          engagement: 200
        }
      }
    end
    it { expect(response).to redirect_to issue_entries_url(issue) }
    it { expect(EntryIssue.find(entry_issue.id).engagement).to eq(200) }
  end
end
