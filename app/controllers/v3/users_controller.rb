class V3::UsersController < V3::ApiController
  before_action :doorkeeper_authorize!, only: [:me, :show, :edit, :update]
  if ENV['BASIC_AUTH_USERNAME'].present? && ENV['BASIC_AUTH_PASSWORD'].present?
    http_basic_authenticate_with name: ENV['BASIC_AUTH_USERNAME'],
                                 password: ENV['BASIC_AUTH_PASSWORD']
  end

  def create
    @user = User.new(email: params[:email],
                     password: params[:password],
                     password_confirmation: params[:password_confirmation])
    @user.type = User::MEMBER
    if @user.save
      render json: @user.to_json, status: :ok
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  def show
    @user = User.find(params[:id])
    render json: @user.to_json, status: :ok
  end

  def me
    render json: current_resource_owner.to_json, status: :ok
  end

  def update
    if params[:id].present?
      if current_resource_owner.id == params[:id] || current_resource_owner.admin?
        @user = User.find(params[:id])
      end
    else
      @user = current_resource_owner
    end
    if !@user.present?
      render json: {}, status: :not_found
    elsif @user.update(profile_params)
      render json: @user.to_json, status: :ok
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  def edit
    @user = current_resource_owner
    render json: @user.to_json(need_picture_put_url: true), status: :ok
  end

  private

  def profile_params
    h = params.permit(:email, :name, :fullName, :locale, :twitter_user_id, :profile, :picture)
    h.merge!({ name: h[:fullName] }) if h.has_key?(:fullName)
    h.delete(:fullName)
    h
  end
end
