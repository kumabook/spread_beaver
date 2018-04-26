# frozen_string_literal: true
require "rails_helper"

describe JournalsController, type: :controller do
  let! (:journal) {     Journal.create!(label: "journal", description: "desc") }
  let  (:user) { FactoryBot.create :admin }

  before(:each) do
    login_user user
  end

  describe "GET index" do
    before { get :index }
    it { expect(assigns(:journals)).to eq([journal])  }
    it { expect(response).to render_template("index") }
  end

  describe "GET new" do
    before { get :new }
    it { expect(response).to render_template("new") }
  end

  describe "POST create" do
    label       = "new_journal"
    description = "desc"
    before { post :create, params: { journal: { label: label, description: description} } }
    it { expect(response).to redirect_to journals_url }
    it { expect(Journal.find_by(label: label).label).to eq(label) }
  end

  describe "GET edit" do
    before { get :edit, params: { id: journal.id } }
    it { expect(response).to render_template("edit") }
  end

  describe "POST update" do
    label = "changed"
    before { post :update, params: { id: journal.id, journal: { label: label } } }
    it { expect(response).to redirect_to journals_url }
    it { expect(Journal.find(journal.id).label).to eq(label) }
  end

  describe "DELETE destroy" do
    before { delete :destroy, params: { id: journal.id } }
    it { expect(response).to redirect_to journals_url }
    it { expect(Journal.find_by(id: journal.id)).to be_nil }
  end
end
