# frozen_string_literal: true

class IdentitiesController < ApplicationController
  before_action :set_type
  before_action :set_identity, only: %i[show destroy crawl]

  def index
    @identities = identity_class.includes(:items).order("name").page(params[:page])
  end

  def search
    per_page    = Kaminari.config.default_per_page
    @identities = enclosure_class.includes(:items).search(@query, params[:page], per_page)
    render "index"
  end

  def show; end

  def destroy
    @identity.destroy
    respond_to do |format|
      format.html {
        redirect_to view_context.index_enc_path(@type),
                    notice: "#{identity_class.name} was successfully destroyed."
      }
    end
  end

  def crawl
    @identity.search_items
    redirect_to view_context.enc_path(@type, @identity),
                notice: "#{identity_class.name} was crawled."
  end

  private

  def identity_class
    case @type
    when "TrackIdentity"
      TrackIdentity
    when "AlbumIdentity"
      AlbumIdentity
    when "PlaylistIdentity"
      PlaylistIdentity
    when "ArtistIdentity"
      ArtistIdentity
    end
  end

  def set_type
    @type = params[:type]
  end

  def set_identity
    @identity = identity_class
                  .eager_load(:items)
                  .find(params[:id])
  end
end
