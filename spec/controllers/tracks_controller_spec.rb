require 'rails_helper'

describe TracksController, type: :controller do
  let! (:track) { FactoryGirl.create(:track) }
  let  (:user ) { FactoryGirl.create(:admin) }

  before(:each) do
    login_user user
  end

  describe '#index' do
    before { get :index }
    it { expect(assigns(:tracks)).to eq([track])  }
    it { expect(response).to render_template("index") }
  end

  describe '#new' do
    before { get :new }
    it { expect(response).to render_template("new") }
  end

  describe '#create' do
    before do
      post :create, params: {
             track: {
               identifier: 'test_identifier',
               provider:   'YouTube',
               title:      'test_track',
               url:        'https;//test.com',
             }
           }
    end
    it { expect(response).to redirect_to tracks_url }
    it { expect(Track.find_by(identifier: 'test_identifier', provider: 'YouTube')).not_to be_nil }
  end

  describe '#edit' do
    before do
      get :edit, params: { id: track.id }
    end
    it { expect(response).to render_template("edit") }
  end

  describe '#update' do
    before do
      post :update, params: {
        id: track.id,
        track: {
          title: 'changed'
        }
      }
    end
    it { expect(response).to redirect_to tracks_url }
    it { expect(Track.find(track.id).title).to eq('changed') }
  end

  describe '#like' do
    before do
      post :like, params: {
             track_id: track.id,
           }
    end
    it { expect(response).to redirect_to tracks_url }
    it { expect(TrackLike.find_by(track_id: track.id, user_id: user.id)).not_to be_nil }
  end

  describe '#unlike' do
    before do
      like = TrackLike.create!(track_id: track.id, user_id: user.id)
      delete :unlike, params: {
               id:       like.id,
               track_id: track.id,
             }
    end
    it { expect(response).to redirect_to tracks_url }
    it { expect(TrackLike.find_by(track_id: track.id, user_id: user.id)).to be_nil }
  end
end
