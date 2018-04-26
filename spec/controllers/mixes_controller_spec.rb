# frozen_string_literal: true

require "rails_helper"

describe MixesController, type: :controller do
  let (:user) { FactoryBot.create(:admin) }
  before(:all) do
    @feed  = FactoryBot.create(:feed)
    @topic = FactoryBot.create(:topic)
  end
  before(:each) do
    login_user user
  end

  describe "#index" do
    before { get :index }
    it { expect(response).to render_template("index") }
  end

  describe "#show" do
    before {
      get :show,
          params: {
            newerThan:  7.days.ago.to_time.to_i * 1000,
            period:     "weekly",
            type:       :hot,
            id:         CGI.escape(@topic.id),
          }
    }
    it { expect(assigns(:items)).not_to be_nil }
    it { expect(response).to render_template("show") }
  end
end
