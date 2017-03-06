# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'spec_helper'
require 'rspec/rails'

Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!

  config.filter_rails_from_backtrace!
  config.include Sorcery::TestHelpers::Rails::Controller, type: :controller
  config.include ApiMacros, :type => :request
end

PER_PAGE           = Kaminari::config::default_per_page
TRACK_PER_ENTRY    = Kaminari::config::default_per_page
PLAYLIST_PER_ENTRY = Kaminari::config::default_per_page
ENTRY_PER_FEED     = (Kaminari::config::default_per_page * 1.5).to_i
ITEM_NUM           = 2
