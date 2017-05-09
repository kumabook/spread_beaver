require 'rails_helper'

describe EntryEnclosuresController, type: :controller do
  let  (:feed  ) { Feed.create!(id: "feed/http://test.com/rss" , title: "feed") }
  let! (:entry) { FactoryGirl.create(:normal_entry, feed: feed )}
  let! (:track) { FactoryGirl.create(:track) }
  let  (:user ) { FactoryGirl.create(:admin       )}
  let  (:entry_enclosure) {
    EntryEnclosure.create!(entry_id: entry.id, enclosure_id: track.id, enclosure_type: Track.name)
  }
  let  (:entry_enclosure_params) {
    {
      entry_enclosure: {
        entry_id:       entry.id,
        enclosure_type: Track.name,
        enclosure_id:   track.id
      }
    }
  }
  before(:each) do
    login_user user
  end

  describe '#new' do
    before { get :new, params: { entry_id: entry.id, type: Track.name } }
    it { expect(response).to render_template("new") }
  end

  describe '#create' do
    context 'when succeeds in creating' do
      before {
        post :create, params: entry_enclosure_params.merge(entry_id: entry.id,
                                                           type:     Track.name)
      }
      it { expect(response).to redirect_to entry_url(entry) }
      it { expect(assigns(:entry)).not_to be_nil }
    end
    context 'when fails to create' do
      before {
        allow_any_instance_of(EntryEnclosure).to receive(:save).and_return(false)
        post :create, params: entry_enclosure_params.merge(entry_id: entry.id,
                                                           type:     Track.name)
      }
      it { expect(response).to redirect_to new_entry_track_url(entry) }
      it { expect(flash[:notice]).not_to be_nil }
    end
  end

  describe '#destroy' do
    context 'when succeeds in saving' do
      before {
        entry_enclosure
        delete :destroy, params: entry_enclosure_params.merge(id:       track.id,
                                                              entry_id: entry.id,
                                                              type:     Track.name)
      }
      it { expect(response).to redirect_to entry_tracks_url(entry) }
      it {
        expect(EntryEnclosure.find_by(entry_id:     entry.id,
                                      enclosure_id: track.id)).to be_nil
      }
    end
    context 'when fails to save' do
      before {
        entry_enclosure
        allow_any_instance_of(EntryEnclosure).to receive(:destroy).and_return(false)
        delete :destroy, params: entry_enclosure_params.merge(id:       track.id,
                                                              entry_id: entry.id,
                                                              type:     Track.name)
      }
      it { expect(response).to redirect_to entry_tracks_url(entry) }
      it {
        expect(EntryEnclosure.find_by(entry_id:     entry.id,
                                      enclosure_id: track.id)).not_to be_nil
      }
    end
  end
end
