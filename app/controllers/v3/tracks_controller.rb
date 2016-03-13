class V3::TracksController < V3::ApiController
  before_action :doorkeeper_authorize!
  before_action :set_track, only: [:show]

  def show
    if @track.present?
      render json: @track.as_json(include: :users), status: 200
    else
      render json: {}, status: :not_found
    end
  end

  def set_track
    @track = Track.includes(:users).find(params[:id])
  end
end
