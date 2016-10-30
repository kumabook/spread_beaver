require 'rails_helper'

describe IssuesController, type: :controller do
  let! (:journal) {     Journal.create!(label: "journal", description: "desc")}
  let! (:issue  ) {       Issue.create!(label: "issue"  , description: "desc", journal_id: journal.id)}
  let  (:user   ) { FactoryGirl.create (:admin                               )}

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
end
