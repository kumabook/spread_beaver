class V3::MarkersController < V3::ApiController
  before_action :doorkeeper_authorize!
  def mark
    @type     = params[:type]
    @action   = request.request_parameters['action']
    @ids      = []
    case @type
    when 'entries'
      mark_entries
    when 'tracks'
      mark_enclosures(:trackIds, Track.name) if params[:trackIds].present?
    when 'playlists'
      mark_enclosures(:playlistIds, Playlist.name) if params[:playlistIds].present?
    when 'albums'
      mark_enclosures(:albumIds, Album.name) if params[:albumIds].present?
    when 'feeds'
      @ids = params[:feedIds] if params[:feedIds].present?
    when 'categories'
      @ids = params[:categoryIds] if params[:categoryIds].present?
    when 'tags'
      @ids = params[:tags]
    end
    @ids = @ids.select {|id| id.present? }
  end

  def mark_entries
    @ids = params[:entryIds] if params[:entryIds].present?
    case @action
    when 'markAsLiked'
      @ids.each do |id|
        begin
          @like = LikedEntry.create(user:     current_resource_owner,
                                    entry_id: id)
        rescue ActiveRecord::RecordNotUnique
        end
      end
      render json: {}, status: 200
    when 'markAsUnliked'
      @ids.each do |id|
        @like = LikedEntry.find_by(user:     current_resource_owner,
                                   entry_id: id)
        @like.destroy if @like.present?
      end
      render json: {}, status: 200
    when 'markAsSaved'
      @ids.each do |id|
        begin
          @saved_entry = SavedEntry.create(user: current_resource_owner,
                                           entry_id: id)
        rescue ActiveRecord::RecordNotUnique
        end
      end
      render json: {}, status: 200
    when 'markAsUnsaved'
      @ids.each do |id|
        @saved_entry = SavedEntry.find_by(user: current_resource_owner,
                                          entry_id: id)
        @saved_entry.destroy if @saved_entry.present?
      end
      render json: {}, status: 200
    when 'markAsRead'
      @ids.each do |id|
        begin
          @read_entry = ReadEntry.create(user: current_resource_owner,
                                         entry_id: id)
        rescue ActiveRecord::RecordNotUnique
        end
      end
      render json: {}, status: 200
    when 'keepUnread'
      @ids.each do |id|
        @read_entry = ReadEntry.find_by(user: current_resource_owner,
                                        entry_id: id)
        @read_entry.destroy if @read_entry.present?
      end
      render json: {}, status: 200
    end
  end

  def mark_enclosures(ids_key, type)
    @ids = params[ids_key] if params[ids_key].present?
    case @action
    when 'markAsLiked'
      @ids.each do |id|
        begin
          @like = LikedEnclosure.create(user:           current_resource_owner,
                                        enclosure_id:   id,
                                        enclosure_type: type)
        rescue ActiveRecord::RecordNotUnique
        end
      end
      render json: {}, status: 200
    when 'markAsUnliked'
      @ids.each do |id|
        @like = LikedEnclosure.find_by(user:         current_resource_owner,
                                       enclosure_id: id)
        @like.destroy if @like.present?
      end
      render json: {}, status: 200
    when 'markAsSaved'
      @ids.each do |id|
        begin
          @save = SavedEnclosure.create(user:           current_resource_owner,
                                        enclosure_id:   id,
                                        enclosure_type: type)
        rescue ActiveRecord::RecordNotUnique
        end
      end
      render json: {}, status: 200
    when 'markAsUnsaved'
      @ids.each do |id|
        @save = SavedEnclosure.find_by(user:         current_resource_owner,
                                       enclosure_id: id)
        @save.destroy if @save.present?
      end
      render json: {}, status: 200
    when /markAsPlayed/
      @ids.each do |id|
        recent_play = PlayedEnclosure
                        .period(1.day.ago, Time.now)
                        .where(user: current_resource_owner,
                               enclosure_id: id)
                        .limit(1)
                        .first
        if recent_play.nil?
          @play = PlayedEnclosure.new(user:           current_resource_owner,
                                      enclosure_id:   id,
                                      enclosure_type: type)
          @play.save
        end
      end
      render json: {}, status: 200
    end
  end
end
