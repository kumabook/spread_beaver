# frozen_string_literal: true

require "spec_helper"

ENV["RAILS_ENV"] ||= "test"
require File.expand_path("../config/environment", __dir__)
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require "rspec/rails"

Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!

  config.render_views
  config.filter_rails_from_backtrace!

  config.include Sorcery::TestHelpers::Rails::Controller, type: :controller
  config.include ApiMacros, type: :request

  config.include PinkSpiderMacros
  config.include RSpotifyMacros
  config.before :each, type: :request do
    mock_up_pink_spider
  end
  config.before :each, type: :controller do
    mock_up_pink_spider
  end

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:all) do
    DatabaseCleaner.start
    DatabaseCleaner[:redis].start
  end

  config.after(:all) do
    DatabaseCleaner.clean
    DatabaseCleaner[:redis].clean
  end

  config.include FactoryBot::Syntax::Methods
end

PER_PAGE           = Kaminari.config.default_per_page
TRACK_PER_ENTRY    = Kaminari.config.default_per_page
ALBUM_PER_ENTRY    = Kaminari.config.default_per_page
PLAYLIST_PER_ENTRY = Kaminari.config.default_per_page
ENTRY_PER_FEED     = (Kaminari.config.default_per_page * 1.5).to_i
ITEM_NUM           = 2
