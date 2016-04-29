class TopicsController < ApplicationController
  before_action :set_topic, only: [:edit, :destroy, :update]
  before_action :require_admin, only: [:new, :create, :destroy, :update]
  def index
    @topics = Topic.order('engagement DESC').all
  end

  def new
    @topic = Topic.new
  end

  def create
    @topic = Topic.new(topic_params)
    respond_to do |format|
      if @topic.save
        format.html { redirect_to topics_path, notice: 'Topic was successfully created.' }
        format.json { render :show, status: :created, location: @topic }
      else
        format.html { redirect_to topics_path, notice: @topic.errors }
        format.json { render json: @topic.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    respond_to do |format|
      if @topic.destroy
        format.html { redirect_to topics_path, notice: 'Topic was successfully destroyed.' }
        format.json { head :no_content }
      else
        format.html { redirect_to topics_path, notice: @topic.errors }
        format.json { render json: @topic.errors, status: :unprocessable_entity }
      end
    end
  end


  def update
    respond_to do |format|
      if @topic.update(topic_params)
        format.html { redirect_to topics_path, notice: 'Topic was successfully updated.' }
        format.json { render :show, status: :ok, location: @topic }
      else
        format.html { render :edit }
        format.json { render json: @topic.errors, status: :unprocessable_entity }
      end
    end
  end

  def set_topic
    @topic = Topic.find(params[:id])
  end

  def topic_params
    params.require(:topic).permit(:id, :label, :description, :engagement)
  end
end
