require 'test_helper'

class TastingLogsControllerTest < ActionController::TestCase
  setup do
    @tasting_log = tasting_logs(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:tasting_logs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create tasting_log" do
    assert_difference('TastingLog.count') do
      post :create, tasting_log: { detail: @tasting_log.detail, order_id: @tasting_log.order_id, store_id: @tasting_log.store_id, tag: @tasting_log.tag, tasting_at: @tasting_log.tasting_at, title: @tasting_log.title }
    end

    assert_redirected_to tasting_log_path(assigns(:tasting_log))
  end

  test "should show tasting_log" do
    get :show, id: @tasting_log
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @tasting_log
    assert_response :success
  end

  test "should update tasting_log" do
    patch :update, id: @tasting_log, tasting_log: { detail: @tasting_log.detail, order_id: @tasting_log.order_id, store_id: @tasting_log.store_id, tag: @tasting_log.tag, tasting_at: @tasting_log.tasting_at, title: @tasting_log.title }
    assert_redirected_to tasting_log_path(assigns(:tasting_log))
  end

  test "should destroy tasting_log" do
    assert_difference('TastingLog.count', -1) do
      delete :destroy, id: @tasting_log
    end

    assert_redirected_to tasting_logs_path
  end
end
