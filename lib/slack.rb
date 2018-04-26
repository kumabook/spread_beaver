# frozen_string_literal: true

require "faraday"

def notify_slack(text)
  return if ENV["SLACK_URL"].nil?
  uri = URI.parse(ENV["SLACK_URL"])
  conn = Faraday.new(url: "#{uri.scheme}://#{uri.host}") do |faraday|
    faraday.request  :url_encoded
    faraday.adapter  Faraday.default_adapter
  end

  conn.post do |req|
    req.url uri.path
    req.headers["Content-Type"] = "application/json"
    req.body = "{ \"text\": \"#{text}\" }"
  end

end
