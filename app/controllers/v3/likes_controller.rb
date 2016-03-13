class Api::V1::LikesController < Api::V1::ApiController
  before_action :doorkeeper_authorize!

  def index
    @likes = Like.where(user: current_resource_owner).includes(:track)
    render json: @likes.map { |l| l.track }.to_json, status: 200
  end
end
