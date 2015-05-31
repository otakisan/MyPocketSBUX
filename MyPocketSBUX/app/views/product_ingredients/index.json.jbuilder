json.array!(@product_ingredients) do |product_ingredient|
  json.extract! product_ingredient, :id, :order_detail_id, :is_custom, :name, :milk_type, :unit_calorie, :unit_price, :quantity, :enabled, :quantity_type, :remarks
  json.url product_ingredient_url(product_ingredient, format: :json)
end
