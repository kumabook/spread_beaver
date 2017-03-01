require 'rails_helper'

describe TrackLikesController, type: :controller do
  let! (:track) { FactoryGirl.create(:track) }
  let  (:user ) { FactoryGirl.create(:admin) }

  before(:each) do
    login_user user
  end

  describe '#create' do
    before do
      post :create, params: {
             track_id: track.id,
           }
    end
    it { expect(response).to redirect_to tracks_url }
    it { expect(TrackLike.find_by(track_id: track.id, user_id: user.id)).not_to be_nil }
  end

  describe '#destroy' do
    before do
      like = TrackLike.create!(track_id: track.id, user_id: user.id)
      delete :destroy, params: {
               id:       like.id,
               track_id: track.id,
             }
    end
    it { expect(response).to redirect_to tracks_url }
    it { expect(TrackLike.find_by(track_id: track.id, user_id: user.id)).to be_nil }
  end
end
