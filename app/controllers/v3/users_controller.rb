class V3::UsersController < V3::ApiController
  before_action :doorkeeper_authorize!, only: [:me, :update]
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

  def me
    render json: current_resource_owner.to_json, status: 200
  end

  def update
    @user = current_resource_owner
    if @user.update(profile_params)
      render json: @user.to_json, status: :ok
    else
      render render json: @user.errors, status: :unprocessable_entity
    end
  end

  def edit
    @user = current_resource_owner
    render json: @user.to_json(need_picture_put_url: true), status: :ok
  end

  private

  def profile_params
    h = params.permit(:email, :name, :fullName, :locale, :twitter_user_id, :profile)
    h.merge!({ name: h[:fullName] }) if h.has_key?(:fullName)
    h.delete(:fullName)
    h
  end
end
