# frozen_string_literal: true

class V3::AuthenticationsController < V3::ApiController
  before_action :doorkeeper_authorize!
  before_action :set_authentication, only: :destroy

  def destroy
    @authentication.destroy
    redirect_to edit_user_path(@authentication.user),
                notice: "Authentication was successfully destroyed."
  end

  private

  def set_authentication
    @user           = current_resource_owner
    @authentication = Authentication.find_by(user_id:  @user.id,
                                             provider: params[:provider])
  end

end
