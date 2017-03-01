class TrackLikesController < ApplicationController
  before_action :set_like, only: [:show, :edit, :update, :destroy]

  # POST /likes
  # POST /likes.json
  def create
    @like = TrackLike.new(like_params.merge(user_id: current_user.id))

    respond_to do |format|
      if @like.save
        format.html { redirect_to tracks_path, notice: 'TrackLike was successfully created.' }
        format.json { render :show, status: :created, location: @like }
      else
        format.html { redirect_to tracks_path, notice: @like.errors }
        format.json { render json: @like.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /likes/1
  # DELETE /likes/1.json
  def destroy
    respond_to do |format|
      if @like.destroy
        format.html { redirect_to tracks_path, notice: 'TrackLike was successfully destroyed.' }
        format.json { head :no_content }
      else
        format.html { redirect_to tracks_path, notice: @like.errors }
        format.json { render json: @like.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_like
      @like = TrackLike.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def like_params
      params.permit(:track_id)
    end
end
