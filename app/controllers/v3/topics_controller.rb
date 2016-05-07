class V3::TopicsController < V3::ApiController
  before_action :doorkeeper_authorize!
  before_action :set_topic,  except: [:index]

  def index
    @topic = Topic.order('engagement DESC').all
    render json: @topic.to_json, status: 200
  end

  def update
    if @topic.update(label: params[:label],
                     description: params[:description])
      render json: @topic.to_json, status: 200
    else
      render json: {}, status: :unprocessable_entity
    end
  end

  def destroy
    if @topic.nil?
      render json: {}, status: :not_found
    elsif @topic.destroy
      render json: {}, status: 200
    else
      render json: {}, status: :unprocessable_entity
    end
  end

  def set_topic
    @topic = Topic.find(CGI.unescape params[:id])
  end
end
