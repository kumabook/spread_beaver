# frozen_string_literal: true

FastlyRails.configure do |c|
  c.api_key                = ENV["FASTLY_API_KEY"]
  c.service_id             = ENV["FASTLY_SERVICE_ID"]
  c.max_age                = 86_400
  c.stale_while_revalidate = 86_400
  c.stale_if_error         = 86_400
  c.purging_enabled        = Rails.env.production? && ENV["FASTLY_API_KEY"].present?
end
