# frozen_string_literal: true

class TopicsController < ApplicationController
  before_action :set_topic, only: %i[edit destroy update mix_issue]
  before_action :require_admin, only: %i[new create destroy update mix_issue]
  def index
    @topics = Topic.order("engagement DESC").all
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

  def mix_issue
    journal = Journal.create_topic_mix_journal(topic)
    redirect_to issue_playlists_path(@topic.find_or_create_mix_issue(journal))
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
