require 'test_helper'

class SeminarsControllerTest < ActionController::TestCase
  setup do
    @seminar = seminars(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:seminars)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create seminar" do
    assert_difference('Seminar.count') do
      post :create, seminar: { capacity: @seminar.capacity, day_of_week: @seminar.day_of_week, deadline: @seminar.deadline, edition: @seminar.edition, end_time: @seminar.end_time, start_time: @seminar.start_time, status: @seminar.status, store_id: @seminar.store_id }
    end

    assert_redirected_to seminar_path(assigns(:seminar))
  end

  test "should show seminar" do
    get :show, id: @seminar
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @seminar
    assert_response :success
  end

  test "should update seminar" do
    patch :update, id: @seminar, seminar: { capacity: @seminar.capacity, day_of_week: @seminar.day_of_week, deadline: @seminar.deadline, edition: @seminar.edition, end_time: @seminar.end_time, start_time: @seminar.start_time, status: @seminar.status, store_id: @seminar.store_id }
    assert_redirected_to seminar_path(assigns(:seminar))
  end

  test "should destroy seminar" do
    assert_difference('Seminar.count', -1) do
      delete :destroy, id: @seminar
    end

    assert_redirected_to seminars_path
  end
end
