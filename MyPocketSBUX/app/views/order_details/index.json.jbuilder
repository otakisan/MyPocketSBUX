json.array!(@order_details) do |order_detail|
  json.extract! order_detail, :id, :order_id, :product_jan_code, :product_name, :size, :hot_or_iced, :reusable_cup, :ticket, :tax_exclude_total_price, :tax_exclude_custom_price, :total_calorie, :custom_calorie, :remarks
  json.url order_detail_url(order_detail, format: :json)
end
