require 'rails_helper'

describe EntriesController, type: :controller do
  let  (:feed  ) { Feed.create!(id: "feed/http://test.com/rss" , title: "feed") }
  let! (:entry) { FactoryGirl.create(:normal_entry, feed: feed )}
  let  (:user ) { FactoryGirl.create(:admin       )}
  let  (:feedly_entry) {
    Hashie::Mash.new(
      title:           'title',
      content:         {},
      summary:         {},
      author:          {},

      alternate:       {},
      origin:          {},
      visual:          {},
      categories:      {},
      unread:          true,

      engagement:      100,
      actionTimestamp: 1.days.ago.to_time.to_i * 1000,
      enclosure:       {},
      fingerprint:     '',
      originId:        '',
      sid:             '',

      crawled:         1.days.ago.to_time.to_i * 1000,
      published:       1.days.ago.to_time.to_i * 1000,
      recrawled:       nil,
      updated:         nil
    )
  }


  before(:each) do
    login_user user
  end

  describe '#index' do
    before { get :index }
    it { expect(assigns(:entries)).to eq([entry])  }
    it { expect(response).to render_template("index") }
  end

  describe '#show' do
    before { get :show, params: { id: entry.id } }
    it { expect(assigns(:entry)).to eq(entry) }
    it { expect(response).to render_template("show") }
  end

  describe '#show_feedly' do
    before {
      allow_any_instance_of(Feedlr::Client).to receive(:user_entry).and_return(feedly_entry)
      get :show_feedly, params: { id: entry.id }
    }
    it { expect(assigns(:entry)).to eq(entry) }
    it { expect(response).to render_template("show_feedly") }
  end

  describe '#new' do
    before { get :new }
    it { expect(response).to render_template("new") }
  end

  describe '#create' do
    hash = nil
    before {
      hash = entry.as_json
      hash.delete('id')
    }
    context 'when succeeds in creating' do
      before {
        post :create, params: { entry: hash }
      }
      it { expect(response).to redirect_to entries_url }
      it { expect(assigns(:entry)).not_to be_nil }
    end
    context 'when fails to create' do
      before {
        allow_any_instance_of(Entry).to receive(:save).and_return(false)
        post :create, params: { entry: hash }
      }
      it { expect(response).to render_template("new") }
      it { expect(flash[:notice]).not_to be_nil }
    end
  end

  describe '#edit' do
    before { get :edit, params: { id: entry.id }}
    it { expect(response).to render_template("edit") }
  end

  describe '#update' do
    title = "changed"
    context 'when succeeds in saving' do
      before { post :update, params: { id: entry.id, entry: { title: title } }}
      it { expect(response).to redirect_to entry_url(entry) }
      it { expect(Entry.find(entry.id).title).to eq(title) }
    end
    context 'when fails to save' do
      before {
        allow_any_instance_of(Entry).to receive(:save).and_return(false)
        post :update, params: { id: entry.id, entry: { title: title } }
      }
      it { expect(response).to render_template("edit") }
    end
  end

  describe "#destroy" do
    context 'when succeeds in saving' do
      before { delete :destroy, params: { id: entry.id }}
      it { expect(response).to redirect_to entries_url }
      it { expect(Entry.find_by(id: entry.id)).to be_nil }
    end
    context 'when fails to save' do
      before {
        allow_any_instance_of(Entry).to receive(:destroy).and_return(false)
        delete :destroy, params: { id: entry.id }
      }
      it { expect(response).to redirect_to entries_url }
    end
  end
end