# frozen_string_literal: true
class V3::MarkersController < V3::ApiController
  before_action :doorkeeper_authorize!
  def mark
    @type     = params[:type]
    @action   = request.request_parameters["action"]
    case @type
    when "entries"
      mark_entries
    when "tracks"
      mark_enclosures(:trackIds, Track.name)
    when "playlists"
      mark_enclosures(:playlistIds, Playlist.name)
    when "albums"
      mark_enclosures(:albumIds, Album.name)
    when "feeds", "categories", "tags"
      # TODO
    end
  end

  def mark_entries
    @ids = params[:entryIds] if params[:entryIds].present?
    @ids = @ids.select {|id| id.present? }
    case @action
    when "markAsLiked"
      mark_items(LikedEntry)
    when "markAsUnliked"
      unmark_items(LikedEntry)
    when "markAsSaved"
      mark_items(SavedEntry)
    when "markAsUnsaved"
      unmark_items(SavedEntry)
    when "markAsRead"
      mark_items(ReadEntry)
    when "keepUnread"
      unmark_items(ReadEntry)
    end
  end

  def mark_enclosures(ids_key, type)
    @ids = params[ids_key] if params[ids_key].present?
    @ids = @ids.select {|id| id.present? }
    case @action
    when "markAsLiked"
      mark_items(LikedEnclosure, type)
    when "markAsUnliked"
      unmark_items(LikedEnclosure, type)
    when "markAsSaved"
      mark_items(SavedEnclosure, type)
    when "markAsUnsaved"
      unmark_items(SavedEnclosure, type)
    when /markAsPlayed/
      mark_items_if_elapsed(PlayedEnclosure, type)
    end
  end

  private
    def mark_items(mark_class, type=nil)
      @ids.each do |id|
        begin
          params = mark_class.marker_params(current_resource_owner, id, type)
          @mark  = mark_class.create(params)
        rescue ActiveRecord::RecordNotUnique
        end
      end
      render json: {}, status: 200
    end

    def unmark_items(mark_class, type=nil)
      @ids.each do |id|
        params = mark_class.marker_params(current_resource_owner, id, type)
        @mark  = mark_class.find_by(params)
        @mark.destroy if @mark.present?
      end
      render json: {}, status: 200
    end

    def mark_items_if_elapsed(mark_class, type, duration=1.day.ago)
      @ids.each do |id|
        recent_play = mark_class
                        .period(duration..Float::INFINITY)
                        .where(user: current_resource_owner, enclosure_id: id)
                        .limit(1)
                        .first
        if recent_play.nil?
          @mark = mark_class.new(user:           current_resource_owner,
                                 enclosure_id:   id,
                                 enclosure_type: type)
          @mark.save
        end
      end
      render json: {}, status: 200
    end
end
