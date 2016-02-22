class Api::V1::CredentialsController < Api::V1::ApiController
  before_action :doorkeeper_authorize!

  # GET /me.json
  def me
    render json: current_resource_owner.to_json, status: 200
  end

end
