require 'test_helper'

class TracksControllerTest < ActionController::TestCase
  setup do
    @track = tracks(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:tracks)
  end

  test "should create track" do
    assert_difference('Track.count') do
      post :create, track: { identifier: @track.identifier, provider: @track.provider, title: @track.title, url: @track.url }
    end

    assert_response 201
  end

  test "should show track" do
    get :show, id: @track
    assert_response :success
  end

  test "should update track" do
    put :update, id: @track, track: { identifier: @track.identifier, provider: @track.provider, title: @track.title, url: @track.url }
    assert_response 204
  end

  test "should destroy track" do
    assert_difference('Track.count', -1) do
      delete :destroy, id: @track
    end

    assert_response 204
  end
end
