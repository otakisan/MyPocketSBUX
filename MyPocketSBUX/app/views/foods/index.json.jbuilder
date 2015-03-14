json.array!(@foods) do |food|
  json.extract! food, :id, :name, :category, :jan_code, :price, :special, :notes, :notification
  json.url food_url(food, format: :json)
end
