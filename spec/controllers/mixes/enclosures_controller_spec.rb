require 'rails_helper'

describe Mixes::EnclosuresController, type: :controller do
  let  (:user) { FactoryBot.create(:admin) }
  before(:all) do
    @feed  = FactoryBot.create(:feed)
    @topic = FactoryBot.create(:topic)
  end
  before(:each) do
    login_user user
  end

  describe '#show' do
    before {
      get :show,
          params: {
            newerThan:  7.days.ago.to_time.to_i * 1000,
            period:     "weekly",
            type:       :engaging,
            id:         CGI.escape(@topic.id),
            enclosures: :tracks,
          }
    }
    it { expect(assigns(:items)).not_to be_nil }
    it { expect(response).to render_template("show") }
  end

end
