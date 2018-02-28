require 'rails_helper'

describe IssuesController, type: :controller do
  let! (:topic) {   Topic.create!(label: "highlight", description: "desc")}
  let! (:journal) { Journal.create!(label: "highlight", description: "desc")}
  let! (:issue  ) { Issue.create!(label: "20170407", description: "desc", journal_id: journal.id)}
  let  (:user   ) { FactoryBot.create (:admin                               )}

  before(:each) do
    login_user user
  end

  describe 'GET index' do
    before { get :index, params: { journal_id: journal.id }}
    it { expect(assigns(:issues)).to eq([issue])  }
    it { expect(response).to render_template("index") }
  end

  describe 'GET new' do
    before { get :new, params: { journal_id: journal.id }}
    it { expect(response).to render_template("new") }
  end

  describe 'POST create' do
    label       = "new_journal"
    description = "desc"
    before { post :create, params: {
                    journal_id: journal.id,
                    issue: { label: label, description: description}
                  }
    }
    it { expect(response).to redirect_to journal_issues_url(journal) }
    it { expect(Issue.find_by(label: label).label).to eq(label) }
  end

  describe 'GET edit' do
    before { get :edit, params: { id: issue.id, journal_id: journal.id }}
    it { expect(response).to render_template("edit") }
  end

  describe 'POST update' do
    label = "changed"
    before { post :update, params: { id: issue.id, journal_id: journal.id, issue: { label: label }}}
    it { expect(response).to redirect_to journal_issues_url(journal) }
    it { expect(Issue.find(issue.id).label).to eq(label) }
  end

  describe "DELETE destroy" do
    before { delete :destroy, params: { id: issue.id, journal_id: journal.id }}
    it { expect(response).to redirect_to journal_issues_url(journal) }
    it { expect(Issue.find_by(id: issue.id)).to be_nil }
  end

  describe "POST create_daily" do
    before {
      post :create_daily, params: {
             journal_id: journal.id,
           }
    }
    it { expect(response).to redirect_to journal_issues_url(journal) }
    it { expect(journal.issues.count).to eq(2) }
  end

  describe "POST collect_entries" do
    before {
      feed  = Feed.create(id: "feed/http://test.com", title: "")
      entry = FactoryBot.create(:normal_entry, feed: feed)
      entry.feed.topics = [topic]
      entry.update!(published: Time.zone.strptime("20170407", "%Y%m%d"))

      entry2 = FactoryBot.create(:normal_entry, feed: feed)
      entry2.feed.topics = [topic]
      entry2.update!(published: Time.zone.strptime("20170409", "%Y%m%d"))

      post :collect_entries, params: {
             journal_id: journal.id,
             id:         issue.id,
           }
    }
    it { expect(response).to redirect_to edit_journal_issue_url(journal, issue) }
    it { expect(issue.entries.count).to eq(1) }
  end
end
