Feedlr.configure do |config|
#  config.oauth_access_token = 'oauth access token'
  config.sandbox = Setting.feedly_target == "sandbox"
#  config.logger = SomeCustomLogger.new
end
