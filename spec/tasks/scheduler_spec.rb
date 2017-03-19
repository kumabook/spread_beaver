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

  before(:each) do
    allow_any_instance_of(Feedlr::Client).to receive(:feeds) do |this, ids|
      ids.map {|id| FeedlrHelper::feed(id) }
    end
    allow_any_instance_of(Feedlr::Client).to receive(:user_entries) do |this, ids|
      ids.map {|id| FeedlrHelper::entry(id) }
    end
    allow_any_instance_of(Feedlr::Client).to receive(:stream_entries_contents) do
      FeedlrHelper::cursor
    end
    @rake[task].reenable
    FactoryGirl.create(:feed)
    FactoryGirl.create(:keyword)
    FactoryGirl.create(:topic)
    Entry.first.update!(visual: nil)
  end

  describe 'crawl' do
    let(:task) { 'crawl' }
    it 'is succeed.' do
      expect(@rake[task].invoke).to be_truthy
    end
  end
end
