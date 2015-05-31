require 'test_helper'

class OrderDetailsControllerTest < ActionController::TestCase
  setup do
    @order_detail = order_details(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:order_details)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create order_detail" do
    assert_difference('OrderDetail.count') do
      post :create, order_detail: { custom_calorie: @order_detail.custom_calorie, hot_or_iced: @order_detail.hot_or_iced, order_id: @order_detail.order_id, product_jan_code: @order_detail.product_jan_code, product_name: @order_detail.product_name, remarks: @order_detail.remarks, reusable_cup: @order_detail.reusable_cup, size: @order_detail.size, tax_exclude_custom_price: @order_detail.tax_exclude_custom_price, tax_exclude_total_price: @order_detail.tax_exclude_total_price, ticket: @order_detail.ticket, total_calorie: @order_detail.total_calorie }
    end

    assert_redirected_to order_detail_path(assigns(:order_detail))
  end

  test "should show order_detail" do
    get :show, id: @order_detail
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @order_detail
    assert_response :success
  end

  test "should update order_detail" do
    patch :update, id: @order_detail, order_detail: { custom_calorie: @order_detail.custom_calorie, hot_or_iced: @order_detail.hot_or_iced, order_id: @order_detail.order_id, product_jan_code: @order_detail.product_jan_code, product_name: @order_detail.product_name, remarks: @order_detail.remarks, reusable_cup: @order_detail.reusable_cup, size: @order_detail.size, tax_exclude_custom_price: @order_detail.tax_exclude_custom_price, tax_exclude_total_price: @order_detail.tax_exclude_total_price, ticket: @order_detail.ticket, total_calorie: @order_detail.total_calorie }
    assert_redirected_to order_detail_path(assigns(:order_detail))
  end

  test "should destroy order_detail" do
    assert_difference('OrderDetail.count', -1) do
      delete :destroy, id: @order_detail
    end

    assert_redirected_to order_details_path
  end
end
