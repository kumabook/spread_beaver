require 'factory_girl'
require 'coveralls'
require 'pink_spider'
require 'simplecov'

Coveralls.wear!('rails')
SimpleCov.formatters = [
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]
SimpleCov.start 'rails'

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
    FactoryGirl.find_definitions
  end

  config.before(:all) do
    DatabaseCleaner.start
    DatabaseCleaner[:redis].start
  end

  config.after(:all) do
    DatabaseCleaner.clean
    DatabaseCleaner[:redis].clean
  end

  config.before(:each) do
    item_hash = {
      "id"    =>  "item_id",
      "url"   => "https://test.com",
      "title" => "item_title"
    }
    allow_any_instance_of(PinkSpider).to receive(:fetch_item).and_return(item_hash)
    allow_any_instance_of(PinkSpider).to receive(:fetch_items).and_return([item_hash])
  end

  config.include FactoryGirl::Syntax::Methods
end

