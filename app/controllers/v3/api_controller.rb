class V3::ApiController < ActionController::API
  include ActionController::Serialization
#  protect_from_forgery with: :null_session
  def current_resource_owner
    User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
  end
end
