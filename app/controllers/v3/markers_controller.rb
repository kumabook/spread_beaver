class V3::MarkersController < V3::ApiController
  before_action :doorkeeper_authorize!
  def mark
    @type     = params[:type]
    @action   = request.request_parameters['action']
    @ids      = []
    case @type
    when 'entries'
      @ids = params[:entryIds] if params[:entryIds].present?
      case @action
      when 'markAsSaved'
        @ids.each do |id|
          @user_entry = UserEntry.create(user: current_resource_owner,
                                     entry_id: id)
        end
        render json: {}, status: 200
        return
      when 'markAsUnsaved'
        @ids.each do |id|
          @user_entry = UserEntry.find_by(user: current_resource_owner,
                                          entry_id: id)
          @user_entry.destroy if @user_entry.present?
        end
        render json: {}, status: 200
        return
      end
    when 'tracks'
      @ids = params[:trackIds] if params[:trackIds].present?
      case @action
      when 'markAsLiked'
        @ids.each do |id|
          @like = Like.new(user: current_resource_owner,
                                 track_id: id)
          @like.save
        end
        render json: {}, status: 200
        return
      when 'markAsUnliked'
        @ids.each do |id|
          @like = Like.find_by(user: current_resource_owner,
                               track_id: id)
          @like.destroy if @like.present?
        end
        render json: {}, status: 200
        return
      end
    when 'feeds'
      @ids = params[:feedIds] if params[:feedIds].present?
    when 'categories'
      @ids = params[:categoryIds] if params[:categoryIds].present?
    when 'tags'
      @ids = params[:tags]
    end
  end
end
