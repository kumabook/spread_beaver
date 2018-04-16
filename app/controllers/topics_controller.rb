class TopicsController < ApplicationController
  before_action :set_topic, only: [:edit, :destroy, :update, :dummy_entry]
  before_action :require_admin, only: [:new, :create, :destroy, :update, :dummy_entry]
  def index
    @topics = Topic.order('engagement DESC').all
  end

  def new
    @topic = Topic.new
  end

  def create
    @topic = Topic.new(topic_params)
    respond_as_create(@topic)
  end

  def destroy
    respond_as_destroy(@topic)
  end

  def update
    respond_as_update(@topic, topic_params)
  end

  def dummy_entry
    redirect_to entry_path(@topic.find_or_create_dummy_entry)
  end

  def set_topic
    @topic = Topic.find(params[:id] || params[:topic_id])
  end

  def topic_params
    params.require(:topic).permit(:id,
                                  :label,
                                  :description,
                                  :locale,
                                  :engagement,
                                  :mix_duration)
  end
end
