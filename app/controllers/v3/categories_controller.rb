class V3::CategoriesController < V3::ApiController
  before_action :doorkeeper_authorize!
  before_action :set_category,  except: [:index]

  def index
    @categories = Category.where(user: current_resource_owner)
    render json: @categories.to_json, status: 200
  end

  def update
    if @category.update(label: params[:label],
                        description: params[:description])
      render json: @category.to_json, status: 200
    else
      render json: {}, status: :unprocessable_entity
    end
  end

  def destroy
    return render json: {}, status: :not_found if @category.nil?
    if @category.destroy
      render json: {}, status: 200
    else
      render json: {}, status: :unprocessable_entity
    end
  end

  def set_category
    @category = Category.find(CGI.unescape params[:id])
  end
end
