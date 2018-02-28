require 'rails_helper'
require 'feedlr_helper'

describe FeedsController, type: :controller do
  let  (:user  ) { FactoryBot.create(:admin) }
  let! (:feed  ) { Feed.create!(id: "feed/http://test.com/rss" , title: "feed") }
  let! (:feed2 ) { Feed.create!(id: "feed/http://test2.com/rss", title: "feed") }
  let! (:topic ) { Topic.create!(label: "topic", description: "desc")}
  let  (:new_url) { "http://new.com/rss" }
  let  (:feedly_feed) { FeedlrHelper::feed("feed/#{new_url}") }
  let  (:pink_spider_feed) { PinkSpiderHelper.feed_hash(new_url) }

  before(:each) do
    login_user user
  end

  describe '#index' do
    context 'with no topic' do
      before { get :index }
      it { expect(assigns(:feeds)).to eq([feed, feed2]) }
      it { expect(response).to render_template("index") }
    end
    context 'with topic' do
      before {
        FeedTopic.create!(feed: feed, topic: topic)
        get :index, params: { topic_id: topic.id }
      }
      it { expect(assigns(:feeds)).to eq([feed])  }
      it { expect(response).to render_template("index") }
    end
  end

  describe '#show' do
    before { get :show, params: { id: CGI.escape(feed.id) }}
    it { expect(response).to render_template("show") }
  end

  describe '#show_feedly' do
    before {
      allow_any_instance_of(Feedlr::Client).to receive(:feed).and_return(feedly_feed)
      get :show_feedly, params: { id: CGI.escape(feed.id) }
    }
    it { expect(response).to render_template("show_feedly") }
  end

  describe '#new' do
    before { get :new }
    it { expect(response).to render_template("new") }
  end

  describe '#create' do
    context 'when feed url does not exist' do
      context "crawler_type = :feedlr" do
        before do
          allow_any_instance_of(Feedlr::Client).to receive(:feeds).and_return([])
          post :create, params: { feed: { url: new_url }}
        end
        it { expect(response).to render_template("new") }
        it { expect(Feed.find_by(id: "feed/#{new_url}")).to be_nil }
        it { expect(flash[:notice]).not_to be_nil }
      end
      context "crawler_type = :pink_spider" do
        before do
          allow_any_instance_of(PinkSpider).to receive(:create_feed).and_return(nil)
          post :create, params: { feed: { url: new_url }}
        end
        it { expect(response).to render_template("new") }
        it { expect(Feed.find_by(id: "feed/#{new_url}")).to be_nil }
        it { expect(flash[:notice]).not_to be_nil }
      end
    end
    context 'when id exists' do
      context "crawler_type = :feedlr" do
        before do
          Feed::crawler_type = :feedlr
          allow_any_instance_of(Feedlr::Client).to receive(:feeds).and_return([feedly_feed])
        end
        context 'when succeeds in creating' do
          before do
            post :create, params: { feed: { url: new_url }}
          end
          it { expect(response).to redirect_to feeds_url }
          it { expect(Feed.find_by(id: "feed/#{new_url}")).not_to be_nil }
        end
        context 'when failes in creating' do
          before do
            allow_any_instance_of(Feed).to receive(:save).and_return(false)
            post :create, params: { feed: { url: new_url }}
          end
          it { expect(response).to redirect_to feeds_url }
          it { expect(flash[:notice]).not_to be_nil }
        end
      end
      context "crawler_type = :pink_spider" do
        before do
          Feed::crawler_type = :pink_spider
          allow_any_instance_of(PinkSpider).to receive(:create_feed).and_return(pink_spider_feed)
        end
        context 'when succeeds in creating' do
          before do
            post :create, params: { feed: { url: new_url }}
          end
          it { expect(response).to redirect_to feeds_url }
          it { expect(Feed.find_by(id: "feed/#{new_url}")).not_to be_nil }
        end
        context 'when failes in creating' do
          before do
            allow_any_instance_of(Feed).to receive(:save).and_return(false)
            post :create, params: { feed: { url: new_url }}
          end
          it { expect(response).to redirect_to feeds_url }
          it { expect(flash[:notice]).not_to be_nil }
        end
      end
    end
  end

  describe '#edit' do
    before { get :edit, params: { id: CGI.escape(feed.id) }}
    it { expect(response).to render_template("edit") }
  end

  describe '#update' do
    title = "changed"
    context 'when succeeds in saving' do
      before {
        post :update, params: {
               id: CGI.escape(feed.id),
               feed: {
                 title: title,
               }
             }
      }
      it { expect(response).to redirect_to feed_url(CGI.escape(feed.id)) }
      it { expect(Feed.find(feed.id).title).to eq(title) }
    end
    context 'when fails to save' do
      before {
        allow_any_instance_of(Feed).to receive(:save).and_return(false)
        post :update, params: { id: CGI.escape(feed.id), feed: { title: title } }
      }
      it { expect(response).to render_template("edit") }
    end
  end

  describe '#destroy' do
    context 'when succeeds in saving' do
      before { delete :destroy, params: { id: CGI.escape(feed.id) }}
      it { expect(response).to redirect_to feeds_url }
      it { expect(Feed.find_by(id: feed.id)).to be_nil }
    end
    context 'when fails to save' do
      before {
        allow_any_instance_of(Feed).to receive(:destroy).and_return(false)
        delete :destroy, params: { id: CGI.escape(feed.id) }
      }
      it { expect(response).to redirect_to feeds_url }
    end
  end
end
