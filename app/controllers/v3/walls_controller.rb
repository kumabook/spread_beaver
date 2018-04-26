# frozen_string_literal: true

class V3::WallsController < V3::ApiController
  before_action :set_wall
  before_action :set_cache_control_headers, only: [:show]

  def show
    set_surrogate_key_header @wall.record_key
    render json: @wall.to_json, status: 200
  end

  def set_wall
    @wall = Wall.preload(:resources).find_by(label: params[:id])
    Resource.set_item_of_stream_resources(@wall.resources)
  end
end
