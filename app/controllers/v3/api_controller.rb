class V3::ApiController < ActionController::API
  include ActionController::Serialization

  rescue_from ActiveRecord::RecordNotFound  ,   with: :render_not_found
  rescue_from ActionController::RoutingError,   with: :render_not_found
  rescue_from ActionController::RoutingError,   with: :render_not_found
  rescue_from ActiveRecord::RecordNotUnique ,   with: :render_conflict

  def render_forbidden
    render json: {}, status: :forbidden
  end

  def render_not_found
    render json: {}, status: :not_found
  end

  def render_conflict
    render json: {}, status: :conflict
  end

  def doorkeeper_unauthorized_render_options(error: nil)
    { json: { error: "Not authorized" } }
  end

#  protect_from_forgery with: :null_session
  def current_resource_owner
    if doorkeeper_token
      User.find(doorkeeper_token.resource_owner_id)
    else
      current_user
    end
  end

  def api_version
    request.headers["X-Api-Version"].to_i
  end
end
