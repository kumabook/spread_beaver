class EntryTracksController < ApplicationController
  before_action :set_entry_track, only: [:show, :update, :destroy]

  # GET /entry_tracks
  # GET /entry_tracks.json
  def index
    @entry_tracks = EntryTrack.all

    render json: @entry_tracks
  end

  # GET /entry_tracks/1
  # GET /entry_tracks/1.json
  def show
    render json: @entry_track
  end

  # POST /entry_tracks
  # POST /entry_tracks.json
  def create
    @entry_track = EntryTrack.new(entry_track_params)

    if @entry_track.save
      render json: @entry_track, status: :created, location: @entry_track
    else
      render json: @entry_track.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /entry_tracks/1
  # PATCH/PUT /entry_tracks/1.json
  def update
    @entry_track = EntryTrack.find(params[:id])

    if @entry_track.update(entry_track_params)
      head :no_content
    else
      render json: @entry_track.errors, status: :unprocessable_entity
    end
  end

  # DELETE /entry_tracks/1
  # DELETE /entry_tracks/1.json
  def destroy
    @entry_track.destroy

    head :no_content
  end

  private

    def set_entry_track
      @entry_track = EntryTrack.find(params[:id])
    end

    def entry_track_params
      params.require(:entry_track).permit(:entry_id, :track_id)
    end
end
