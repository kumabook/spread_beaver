class V3::UsersController < V3::ApiController
  if ENV['BASIC_AUTH_USERNAME'].present? && ENV['BASIC_AUTH_PASSWORD'].present?
    http_basic_authenticate_with name: ENV['BASIC_AUTH_USERNAME'],
                                 password: ENV['BASIC_AUTH_PASSWORD']
  end

  def create
    @user = User.new(email: params[:email],
                     password: params[:password],
                     password_confirmation: params[:password_confirmation])
    @user.type = User.types[:member]
    if @user.save
      render json: @user.to_json, status: :ok
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end
end
