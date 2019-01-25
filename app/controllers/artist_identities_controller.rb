# frozen_string_literal: true

class ArtistIdentitiesController < ApplicationController
  before_action :set_identity, only: %i[show edit update destroy crawl]

  def index
    @identities = ArtistIdentity.includes(:items).order("name").page(params[:page])
  end

  def search
    per_page    = Kaminari.config.default_per_page
    @identities = ArtistIdentity.includes(:items).search(params[:query], params[:page], per_page)
    render "index"
  end

  def show; end

  def edit; end

  def update
    @identity.update_attributes(artist_identity_params)
    respond_to do |format|
      if @identity.save
        format.html { redirect_to artist_identity_path(@identity), notice: "ArtistIdentity was successfully updated." }
        format.json { render :show, status: :ok, location: @identity }
      else
        format.html { render "edit" }
        format.json { render json: @identity.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @identity.destroy
    respond_to do |format|
      format.html {
        redirect_to view_context.index_enc_path("ArtistIdentity"),
                    notice: "ArtistIdentity was successfully destroyed."
      }
    end
  end

  def crawl
    @identity.search_items
    redirect_to view_context.enc_path("ArtistIdentity", @identity),
                notice: "#{ArtistIdentity.name} was crawled."
  end

  private

  def set_identity
    @identity = ArtistIdentity
                .eager_load(:items)
                .find(params[:id])
  end

  def artist_identity_params
    params.require(:artist_identity).permit(:id,
                                            :name,
                                            :slug,
                                            :bio,
                                            :bio_en,
                                            :wikipedia,
                                            :website,
                                            :facebook,
                                            :instagram,
                                            :twitter)
  end
end
