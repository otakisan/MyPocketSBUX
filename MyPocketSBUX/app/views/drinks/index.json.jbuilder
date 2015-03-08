json.array!(@drinks) do |drink|
  json.extract! drink, :id, :name, :category, :jan_code, :price, :special, :notes, :notification, :size, :milk
  json.url drink_url(drink, format: :json)
end
