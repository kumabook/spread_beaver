FastlyRails.configure do |c|
  c.api_key                = ENV["FASTLY_API_KEY"]
  c.service_id             = ENV["FASTLY_SERVICE_ID"]
  c.max_age                = 86400
  c.stale_while_revalidate = 86400
  c.stale_if_error         = 86400
  c.purging_enabled        = !Rails.env.development?
end
