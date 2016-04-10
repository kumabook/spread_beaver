class V3::TracksController < V3::ApiController
  before_action :doorkeeper_authorize!
  before_action :set_track,  only: [:show]
  before_action :set_tracks, only: [:list]

  def show
    if @track.present?
      render json: @track.as_detail_json, status: 200
    else
      render json: {}, status: :not_found
    end
  end

  def set_track
    @track = Track.detail.find(params[:id])
  end

  def list
    if @tracks.present?
      render json: @tracks.map {|t|
        t.as_detail_json
      }.to_json, status: 200
    else
      render json: {}, status: :not_found
    end
  end

  def set_tracks
    @tracks = Track.detail.find(params['_json'])
  end

end
