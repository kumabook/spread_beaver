class V3::KeywordsController < V3::ApiController
  before_action :doorkeeper_authorize!
  before_action :set_keyword,  except: [:index]

  def index
    @keyword = Keyword.order('label ASC').all
    render json: @keyword.to_json, status: 200
  end

  def update
    if @keyword.update(label: params[:label],
                 description: params[:description])
      render json: @keyword.to_json, status: 200
    else
      render json: {}, status: :unprocessable_entity
    end
  end

  def destroy
    if @keyword.nil?
      render json: {}, status: :not_found
    elsif @keyword.destroy
      render json: {}, status: 200
    else
      render json: {}, status: :unprocessable_entity
    end
  end

  def set_keyword
    @keyword = Keyword.find(CGI.unescape params[:id])
  end
end
