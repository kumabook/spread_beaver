class V3::TopicsController < V3::ApiController
  before_action :doorkeeper_authorize!, except: [:index]
  before_action :set_topic,  except: [:index]

  def index
    locale  = params[:locale]
    @topics = Topic.topics(locale)
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
    @topic = Topic.find(CGI.unescape params[:id])
  end
end
