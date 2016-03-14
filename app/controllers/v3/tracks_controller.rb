class V3::TracksController < V3::ApiController
  before_action :doorkeeper_authorize!
  before_action :set_track,  only: [:show]
  before_action :set_tracks, only: [:list]

  def show
    if @track.present?
      render json: @track.as_json(include: {
                                    likers: {
                                      except: [:crypted_password, :salt]
                                    }
                                  }), status: 200
    else
      render json: {}, status: :not_found
    end
  end

  def set_track
    @track = Track.includes(:users).find(params[:id])
  end

  def list
    if @tracks.present?
      render json: @tracks.map {|t|
        t.as_json(include: {users: {except: [:crypted_password, :salt]}})
      }.to_json, status: 200
    else
      render json: {}, status: :not_found
    end
  end

  def set_tracks
    @tracks = Track.includes(:users).find(params['_json'])
  end

end
