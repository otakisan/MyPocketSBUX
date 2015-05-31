require 'test_helper'

class ProductIngredientsControllerTest < ActionController::TestCase
  setup do
    @product_ingredient = product_ingredients(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:product_ingredients)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create product_ingredient" do
    assert_difference('ProductIngredient.count') do
      post :create, product_ingredient: { enabled: @product_ingredient.enabled, is_custom: @product_ingredient.is_custom, milk_type: @product_ingredient.milk_type, name: @product_ingredient.name, order_detail_id: @product_ingredient.order_detail_id, quantity: @product_ingredient.quantity, quantity_type: @product_ingredient.quantity_type, remarks: @product_ingredient.remarks, unit_calorie: @product_ingredient.unit_calorie, unit_price: @product_ingredient.unit_price }
    end

    assert_redirected_to product_ingredient_path(assigns(:product_ingredient))
  end

  test "should show product_ingredient" do
    get :show, id: @product_ingredient
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @product_ingredient
    assert_response :success
  end

  test "should update product_ingredient" do
    patch :update, id: @product_ingredient, product_ingredient: { enabled: @product_ingredient.enabled, is_custom: @product_ingredient.is_custom, milk_type: @product_ingredient.milk_type, name: @product_ingredient.name, order_detail_id: @product_ingredient.order_detail_id, quantity: @product_ingredient.quantity, quantity_type: @product_ingredient.quantity_type, remarks: @product_ingredient.remarks, unit_calorie: @product_ingredient.unit_calorie, unit_price: @product_ingredient.unit_price }
    assert_redirected_to product_ingredient_path(assigns(:product_ingredient))
  end

  test "should destroy product_ingredient" do
    assert_difference('ProductIngredient.count', -1) do
      delete :destroy, id: @product_ingredient
    end

    assert_redirected_to product_ingredients_path
  end
end
