require "faraday"

def notify_slack(text)
  uri = URI.parse(ENV["SLACK_URL"])
  return if uri.nil?
  conn = Faraday.new(:url => "#{uri.scheme}://#{uri.host}") do |faraday|
    faraday.request  :url_encoded
    faraday.adapter  Faraday.default_adapter
  end

  conn.post do |req|
    req.url uri.path
    req.headers['Content-Type'] = 'application/json'
    req.body = "{ \"text\": \"#{text}\" }"
  end

end
