require 'test_helper'

class TunesControllerTest < ActionController::TestCase
  setup do
    @tune = tunes(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:tunes)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create tune" do
    assert_difference('Tune.count') do
      post :create, tune: { artist_id: @tune.artist_id, artist_name: @tune.artist_name, artist_view_url: @tune.artist_view_url, artwork_url_100: @tune.artwork_url_100, artwork_url_30: @tune.artwork_url_30, artwork_url_60: @tune.artwork_url_60, collection_censored_name: @tune.collection_censored_name, collection_explicitness: @tune.collection_explicitness, collection_id: @tune.collection_id, collection_name: @tune.collection_name, collection_price: @tune.collection_price, collection_view_url: @tune.collection_view_url, country: @tune.country, currency: @tune.currency, disc_count: @tune.disc_count, disc_number: @tune.disc_number, kind: @tune.kind, preview_url: @tune.preview_url, primary_genre_name: @tune.primary_genre_name, radio_station_url: @tune.radio_station_url, release_date: @tune.release_date, track_censored_name: @tune.track_censored_name, track_count: @tune.track_count, track_explicitness: @tune.track_explicitness, track_id: @tune.track_id, track_name: @tune.track_name, track_number: @tune.track_number, track_price: @tune.track_price, track_time_millis: @tune.track_time_millis, track_view_url: @tune.track_view_url, wrapper_type: @tune.wrapper_type }
    end

    assert_redirected_to tune_path(assigns(:tune))
  end

  test "should show tune" do
    get :show, id: @tune
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @tune
    assert_response :success
  end

  test "should update tune" do
    patch :update, id: @tune, tune: { artist_id: @tune.artist_id, artist_name: @tune.artist_name, artist_view_url: @tune.artist_view_url, artwork_url_100: @tune.artwork_url_100, artwork_url_30: @tune.artwork_url_30, artwork_url_60: @tune.artwork_url_60, collection_censored_name: @tune.collection_censored_name, collection_explicitness: @tune.collection_explicitness, collection_id: @tune.collection_id, collection_name: @tune.collection_name, collection_price: @tune.collection_price, collection_view_url: @tune.collection_view_url, country: @tune.country, currency: @tune.currency, disc_count: @tune.disc_count, disc_number: @tune.disc_number, kind: @tune.kind, preview_url: @tune.preview_url, primary_genre_name: @tune.primary_genre_name, radio_station_url: @tune.radio_station_url, release_date: @tune.release_date, track_censored_name: @tune.track_censored_name, track_count: @tune.track_count, track_explicitness: @tune.track_explicitness, track_id: @tune.track_id, track_name: @tune.track_name, track_number: @tune.track_number, track_price: @tune.track_price, track_time_millis: @tune.track_time_millis, track_view_url: @tune.track_view_url, wrapper_type: @tune.wrapper_type }
    assert_redirected_to tune_path(assigns(:tune))
  end

  test "should destroy tune" do
    assert_difference('Tune.count', -1) do
      delete :destroy, id: @tune
    end

    assert_redirected_to tunes_path
  end
end
