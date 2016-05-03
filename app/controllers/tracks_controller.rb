class TracksController < ApplicationController
  before_action :set_track, only: [:show, :edit, :update, :destroy]
  before_action :set_entry, only: [:index]

  # GET /tracks
  # GET /tracks.json
  def index
    if @entry.present?
      @tracks = @entry.tracks.page(params[:page])
      @likes  = Like.where(user_id: current_user.id,
                          track_id: @tracks.map { |t| t.id })
    else
      @tracks = Track.order('created_at DESC').page(params[:page])
      @likes  = Like.where(user_id: current_user.id,
                          track_id: @tracks.map { |t| t.id })
    end
  end

  # GET /tracks/1
  # GET /tracks/1.json
  def show
  end

  def new
    @track = Track.new
  end

  # POST /tracks
  # POST /tracks.json
  def create
    @track = Track.new(track_params)

    if @track.save
      format.html { redirect_to tracks_path, notice: 'Track was successfully created.' }
    else
      format.html { render :new }
    end
  end

  # PATCH/PUT /tracks/1
  # PATCH/PUT /tracks/1.json
  def update
    if @track.update(track_params)
      format.html { redirect_to tracks_path, notice: 'Track was successfully updated.' }
    else
      format.html { render :edit }
    end
  end

  # DELETE /tracks/1
  # DELETE /tracks/1.json
  def destroy
    @track.destroy
    respond_to do |format|
      format.html { redirect_to tracks_path, notice: 'Track was successfully destroyed.' }
    end
  end

  private

    def set_track
      @track = Track.find(params[:id])
    end

    def set_entry
      @entry = Entry.find(params[:entry_id]) if params[:entry_id].present?
    end

    def track_params
      params.require(:track).permit(:identifier, :provider, :title, :url)
    end
end
