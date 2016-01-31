require 'test_helper'

class UserEntriesControllerTest < ActionController::TestCase
  setup do
    @user_entry = user_entries(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:user_entries)
  end

  test "should create user_entry" do
    assert_difference('UserEntry.count') do
      post :create, user_entry: { entry_id: @user_entry.entry_id, user_id: @user_entry.user_id }
    end

    assert_response 201
  end

  test "should show user_entry" do
    get :show, id: @user_entry
    assert_response :success
  end

  test "should update user_entry" do
    put :update, id: @user_entry, user_entry: { entry_id: @user_entry.entry_id, user_id: @user_entry.user_id }
    assert_response 204
  end

  test "should destroy user_entry" do
    assert_difference('UserEntry.count', -1) do
      delete :destroy, id: @user_entry
    end

    assert_response 204
  end
end
