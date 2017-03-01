class TracksController < ApplicationController
  before_action :set_track, only: [:show, :edit, :update, :destroy]
  before_action :set_entry, only: [:index]

  # GET /tracks
  # GET /tracks.json
  def index
    if @entry.present?
      @tracks = @entry.tracks.page(params[:page])
    else
      @tracks = Track.order('created_at DESC').page(params[:page])
    end
    my_likes = TrackLike.where(user_id: current_user.id,
                         track_id: @tracks.map { |t| t.id })
    count = TrackLike.where(track_id: @tracks.map { |t| t.id })
                .group(:track_id).count('track_id')
    @likes_dic = @tracks.inject({}) do |h, t|
      h[t] = {
        my: my_likes.to_a.select {|l| t.id == l.track_id }.first,
        count: count.to_a.select {|c| t.id == c[0] }.map {|c| c[1] }.first,
      }
      h
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

    respond_to do |format|
      if @track.save
        format.html { redirect_to tracks_path, notice: 'Track was successfully created.' }
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /tracks/1
  # PATCH/PUT /tracks/1.json
  def update

    respond_to do |format|
      if @track.update(track_params)
        format.html { redirect_to tracks_path, notice: 'Track was successfully updated.' }
      else
        format.html { render :edit }
      end
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
