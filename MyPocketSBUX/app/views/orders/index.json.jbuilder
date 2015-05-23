json.array!(@orders) do |order|
  json.extract! order, :id, :store_id, :tax_excluded_total_price, :tax_included_total_price, :remarks, :notes
  json.url order_url(order, format: :json)
end
