require 'test_helper'

class StoresControllerTest < ActionController::TestCase
  setup do
    @store = stores(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:stores)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create store" do
    assert_difference('Store.count') do
      post :create, store: { access: @store.access, address: @store.address, closing_time_holiday: @store.closing_time_holiday, closing_time_saturday: @store.closing_time_saturday, closing_time_weekday: @store.closing_time_weekday, holiday: @store.holiday, latitude: @store.latitude, longitude: @store.longitude, name: @store.name, notes: @store.notes, opening_time_holiday: @store.opening_time_holiday, opening_time_saturday: @store.opening_time_saturday, opening_time_weekday: @store.opening_time_weekday, phone_number: @store.phone_number, pref_id: @store.pref_id, store_id: @store.store_id }
    end

    assert_redirected_to store_path(assigns(:store))
  end

  test "should show store" do
    get :show, id: @store
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @store
    assert_response :success
  end

  test "should update store" do
    patch :update, id: @store, store: { access: @store.access, address: @store.address, closing_time_holiday: @store.closing_time_holiday, closing_time_saturday: @store.closing_time_saturday, closing_time_weekday: @store.closing_time_weekday, holiday: @store.holiday, latitude: @store.latitude, longitude: @store.longitude, name: @store.name, notes: @store.notes, opening_time_holiday: @store.opening_time_holiday, opening_time_saturday: @store.opening_time_saturday, opening_time_weekday: @store.opening_time_weekday, phone_number: @store.phone_number, pref_id: @store.pref_id, store_id: @store.store_id }
    assert_redirected_to store_path(assigns(:store))
  end

  test "should destroy store" do
    assert_difference('Store.count', -1) do
      delete :destroy, id: @store
    end

    assert_redirected_to stores_path
  end
end
