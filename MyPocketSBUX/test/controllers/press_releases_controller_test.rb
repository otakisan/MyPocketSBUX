require 'test_helper'

class PressReleasesControllerTest < ActionController::TestCase
  setup do
    @press_release = press_releases(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:press_releases)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create press_release" do
    assert_difference('PressRelease.count') do
      post :create, press_release: { fiscal_year: @press_release.fiscal_year, press_release_sn: @press_release.press_release_sn, title: @press_release.title, url: @press_release.url }
    end

    assert_redirected_to press_release_path(assigns(:press_release))
  end

  test "should show press_release" do
    get :show, id: @press_release
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @press_release
    assert_response :success
  end

  test "should update press_release" do
    patch :update, id: @press_release, press_release: { fiscal_year: @press_release.fiscal_year, press_release_sn: @press_release.press_release_sn, title: @press_release.title, url: @press_release.url }
    assert_redirected_to press_release_path(assigns(:press_release))
  end

  test "should destroy press_release" do
    assert_difference('PressRelease.count', -1) do
      delete :destroy, id: @press_release
    end

    assert_redirected_to press_releases_path
  end
end
