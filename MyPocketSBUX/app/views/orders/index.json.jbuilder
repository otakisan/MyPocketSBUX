json.array!(@orders) do |order|
  json.extract! order, :id, :store_id, :tax_excluded_total_price, :tax_included_total_price, :remarks, :notes, :created_at, :updated_at
  #json.extract! order, :id, :store_id, :tax_excluded_total_price, :tax_included_total_price, :remarks, :notes, :created_at, :updated_at, :order_details
  json.url order_url(order, format: :json)

  #json.order_details json.array!(order.order_details) do |order_detail|
    #json.extract! order_detail, :id, :order_id, :product_jan_code, :product_name, :size, :hot_or_iced, :reusable_cup, :ticket, :tax_exclude_total_price, :tax_exclude_custom_price, :total_calorie, :custom_calorie, :remarks, :created_at, :updated_at
  #end

  #json.order_details order.order_details do |json, order_detail|
    #json.(order_detail , :id, :order_id, :product_jan_code, :product_name, :size, :hot_or_iced, :reusable_cup, :ticket, :tax_exclude_total_price, :tax_exclude_custom_price, :total_calorie, :custom_calorie, :remarks, :created_at, :updated_at)
    #json.extract! order_detail, :id, :order_id, :product_jan_code, :product_name, :size, :hot_or_iced, :reusable_cup, :ticket, :tax_exclude_total_price, :tax_exclude_custom_price, :total_calorie, :custom_calorie, :remarks, :created_at, :updated_at
  #end

  json.order_details(order.order_details, :id, :order_id, :product_jan_code, :product_name, :size, :hot_or_iced, :reusable_cup, :ticket, :tax_exclude_total_price, :tax_exclude_custom_price, :total_calorie, :custom_calorie, :remarks, :created_at, :updated_at, :product_ingredients)
end
