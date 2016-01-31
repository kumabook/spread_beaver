require 'test_helper'

class EntryTracksControllerTest < ActionController::TestCase
  setup do
    @entry_track = entry_tracks(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:entry_tracks)
  end

  test "should create entry_track" do
    assert_difference('EntryTrack.count') do
      post :create, entry_track: { entry_id: @entry_track.entry_id, track_id: @entry_track.track_id }
    end

    assert_response 201
  end

  test "should show entry_track" do
    get :show, id: @entry_track
    assert_response :success
  end

  test "should update entry_track" do
    put :update, id: @entry_track, entry_track: { entry_id: @entry_track.entry_id, track_id: @entry_track.track_id }
    assert_response 204
  end

  test "should destroy entry_track" do
    assert_difference('EntryTrack.count', -1) do
      delete :destroy, id: @entry_track
    end

    assert_response 204
  end
end
