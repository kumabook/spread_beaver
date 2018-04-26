# frozen_string_literal: true

require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module SpreadBeaver
  class Application < Rails::Application
    config.load_defaults 5.1
    config.time_zone = "Tokyo"
    config.api_only = false

    config.action_dispatch.default_headers = {
      "Access-Control-Allow-Origin"      =>  ENV["ACCESS_CONTROL_ALLOW_ORIGIN"] || "*",
      "Access-Control-Allow-Credentials" => "true",
      "Access-Control-Request-Method"    => "*",
      "Access-Control-Allow-Headers"     => "Accept,Authorization,Cache-Control,Content-Type,DNT,If-Modified-Since,Keep-Alive,Origin,User-Agent,X-Mx-ReqToken,X-Requested-With",
    }
  end
end
