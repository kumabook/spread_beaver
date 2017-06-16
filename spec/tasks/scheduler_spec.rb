require 'rails_helper'
require 'feedlr_helper'
require 'rake'

describe 'rake task crawl' do
  before(:all) do
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake.application.rake_require 'tasks/scheduler'
    Rake::Task.define_task(:environment)
  end

  before do
    @rake[task].reenable
    FactoryGirl.create(:feed)
    FactoryGirl.create(:keyword)
    FactoryGirl.create(:topic)
    Entry.first.update!(visual: nil)
  end

  describe 'crawl' do
    let(:task) { 'crawl' }
    context "crawler_type = :feeldr" do
      before do
        Feed::crawler_type = :feedlr
        allow_any_instance_of(Feedlr::Client).to receive(:feeds) do |this, ids|
          ids.map {|id| FeedlrHelper::feed(id) }
        end
        allow_any_instance_of(Feedlr::Client).to receive(:user_entries) do |this, ids|
          ids.map {|id| FeedlrHelper::entry(id) }
        end
        allow_any_instance_of(Feedlr::Client).to receive(:stream_entries_contents) do
          FeedlrHelper::cursor
        end
      end
      it 'is succeed.' do
        expect(@rake[task].invoke).to be_truthy
      end
    end

    context "craawler_type = :pink_spider" do
      before do
        Feed::crawler_type = :pink_spider
        allow_any_instance_of(PinkSpider).to receive(:fetch_entries_of_feed) do
          {
            page:     0,
            per_page: 1,
            total:    1,
            items:    [PinkSpiderHelper::entry_hash(url: 'http://example.com/entry1')]
          }.with_indifferent_access
        end
      end
      it 'is succeed.' do
        expect(@rake[task].invoke).to be_truthy
      end
    end
  end

  describe 'create_daily_issue' do
    before do
      FactoryGirl.create(:feed)
      Journal.create!(label: 'highlight')
      topic       = Topic.create!(label: 'highlight')
      feed        = Feed.first
      feed.topics = [topic]
      feed.save!
    end

    let(:task) { 'create_daily_issue' }
    it 'is succeed.' do
      expect(@rake[task].invoke).to be_truthy
    end
  end
end
