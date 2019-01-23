# frozen_string_literal: true

class V3::EnclosuresController < V3::ApiController
  include Pagination
  before_action :set_enclosure_class
  before_action :set_enclosure            , only: [:show]
  before_action :set_enclosure_by_slug    , only: [:show_by_slug]
  before_action :set_enclosures           , only: [:list]
  before_action :set_entry                , only: [:index]
  before_action :set_playlist             , only: [:index]
  before_action :set_track                , only: [:index]
  before_action :set_page                 , only: [:index]
  before_action :set_cache_control_headers

  def show
    set_surrogate_key_header @enclosure.record_key
    if @enclosure.present?
      render json: @enclosure.as_detail_json, status: 200
    else
      render_not_found
    end
  end

  def show_by_slug
    show
  end

  def list
    if !@enclosures.nil?
      render json: @enclosures.map(&:as_detail_json).to_json, status: 200
    else
      render_not_found
    end
  end

  def index
    if @entry.present?
      @entry_enclosures = @entry.entry_enclosures
                                .page(params[:page])
      @enclosures = @entry.public_send(index_method)
                          .page(params[:page])
    elsif @playlist.present? && @enclosure_class == Track
      @enclosures = @playlist.pick_enclosures.page(@page).per(@per_page)
    elsif @track.present? && @enclosure_class == Playlist
      @enclosures = @track.pick_containers.page(@page).per(@per_page)
    else
      @enclosures = []
    end
    continuation = self.class.calculate_continuation(@enclosures, @page, @per_page)
    @enclosure_class.set_marks(current_user, @enclosures) if current_user.present?
    set_surrogate_key_header @enclosure_class.table_key, @enclosures.map(&:record_key)
    h = {
      continuation: continuation,
      items: @enclosures.map(&:as_content_json),
    }
    render json: h, status: 200
  end

  private

  def set_entry
    @entry = Entry.find(params[:entry_id]) if params[:entry_id].present?
  end

  def set_playlist
    @playlist = Playlist.find(params[:playlist_id]) if params[:playlist_id].present?
  end

  def set_track
    @track = Track.find(params[:track_id]) if params[:track_id].present?
  end

  def set_enclosure
    @enclosure = @enclosure_class.with_detail.find(params[:id])
    set_enclosure_items
  end

  def set_enclosure_by_slug
    @enclosure = @enclosure_class.with_detail.find_by(slug: params[:slug])
    set_enclosure_items
  end

  def set_enclosure_items
    enclosures = [@enclosure] + @enclosure.pick_enclosures + @enclosure.pick_containers
    @enclosure_class.set_partial_entries(enclosures)
    if current_resource_owner.present?
      @enclosure_class.set_marks(current_resource_owner, [@enclosure])
    end
  end

  def set_enclosures
    @enclosures = @enclosure_class.with_detail.where(id: params["_json"])
    @enclosures = params["_json"].flat_map { |id|
      @enclosures.select { |v| v.id == id }
    }
    enclosures = @enclosures.flat_map { |e| [] + e.pick_enclosures + e.pick_containers }
    @enclosure_class.set_partial_entries(enclosures)
    if current_resource_owner.present?
      @enclosure_class.set_marks(current_resource_owner, @enclosures)
    end
  end

  def set_enclosure_class
    @enclosure_class = params[:type].constantize
  end

end
