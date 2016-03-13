class V3::CredentialsController < V3::ApiController
  before_action :doorkeeper_authorize!

  # GET /me.json
  def me
    render json: current_resource_owner.to_json, status: 200
  end

end
