# frozen_string_literal: true
class V3::KeywordsController < V3::ApiController
  before_action :doorkeeper_authorize!
  before_action :set_keyword,  except: [:index]
  before_action :set_cache_control_headers, only: [:index]

  def index
    @keywords = Keyword.order("label ASC").all
    set_surrogate_key_header Keyword.table_key, @keywords.map(&:record_key)
    render json: @keywords.to_json, status: 200
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
    @keyword = Keyword.find(CGI.unescape(params[:id]))
  end
end
