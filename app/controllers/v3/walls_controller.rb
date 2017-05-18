class V3::WallsController < V3::ApiController
  before_action :set_wall

  def show
    render json: @wall.to_json, status: 200
  end

  def set_wall
    @wall = Wall.preload(:resources).find_by(label: params[:id])
    Resource.set_item_of_stream_resources(@wall.resources)
  end
end
