require 'rails_helper'

describe EnclosuresController, type: :controller do
  let  (:uuid ) { SecureRandom.uuid }
  let! (:track) { FactoryGirl.create(:track) }
  let  (:user ) { FactoryGirl.create(:admin) }

  before(:each) do
    login_user user
  end

  describe '#index' do
    before { get :index, params: { type: 'Track' } }
    it { expect(assigns(:enclosures)).to eq([track])  }
    it { expect(response).to render_template("index") }
  end

  describe '#new' do
    before { get :new, params: { type: 'Track' } }
    it { expect(response).to render_template("new") }
  end

  describe '#create' do
    before do
      post :create, params: {
             type: 'Track',
             track: {
               id: uuid
             }
           }
    end
    it { expect(response).to redirect_to tracks_url }
    it { expect(Track.find_by(id: uuid)).not_to be_nil }
  end

  describe '#like' do
    before do
      post :like, params: {
             type:     'Track',
             track_id: track.id,
           }
    end
    it { expect(response).to redirect_to tracks_url }
    it { expect(EnclosureLike.find_by(enclosure_id: track.id, user_id: user.id)).not_to be_nil }
  end

  describe '#unlike' do
    before do
      like = EnclosureLike.create!(enclosure_id: track.id, user_id: user.id)
      delete :unlike, params: {
               type:     'Track',
               id:       like.id,
               track_id: track.id,
             }
    end
    it { expect(response).to redirect_to tracks_url }
    it { expect(EnclosureLike.find_by(enclosure_id: track.id, user_id: user.id)).to be_nil }
  end
end
