require 'rails_helper'
require 'feedlr_helper'
require 'rake'

describe 'rake task recrawl' do
  before(:all) do
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake.application.rake_require 'tasks/recrawl'
    Rake::Task.define_task(:environment)
  end

  before(:each) do
    id = "http://new.com/rss"
    allow_any_instance_of(Feedlr::Client).to receive(:feeds) do
      [FeedlrHelper::feed(id)]
    end
    allow_any_instance_of(Feedlr::Client).to receive(:user_entry) do |this|
      FeedlrHelper::entry(id)
    end
    @rake[task].reenable
    FactoryGirl.create(:feed)
    FactoryGirl.create(:feed)
    FactoryGirl.create(:keyword)
    FactoryGirl.create(:topic)
  end

  describe 'recrawl' do
    let(:task) { 'recrawl' }
    it 'is succeed.' do
      expect(@rake[task].invoke).to be_truthy
    end
  end
end
