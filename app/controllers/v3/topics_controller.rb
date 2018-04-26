# frozen_string_literal: true
class V3::TopicsController < V3::ApiController
  before_action :doorkeeper_authorize!, except: [:index]
  before_action :set_topic,  except: [:index]
  before_action :set_cache_control_headers, only: [:index]

  def index
    locale  = params[:locale]
    if locale.nil?
      locale = "ja"
    end
    @topics = Topic.topics(locale)
    set_surrogate_key_header Topic.table_key, @topics.map(&:record_key)
    render json: @topics.to_json, status: 200
  end

  def update
    if @topic.update(label:       params[:label],
                     description: params[:description],
                     locale:      params[:locale])
      render json: @topic.to_json, status: 200
    else
      render json: {}, status: :unprocessable_entity
    end
  end

  def destroy
    if @topic.nil?
      render_not_found
    elsif @topic.destroy
      render json: {}, status: 200
    else
      render json: {}, status: :unprocessable_entity
    end
  end

  def set_topic
    @topic = Topic.find(CGI.unescape(params[:id]))
  end
end
