json.array!(@nutritions) do |nutrition|
  json.extract! nutrition, :id, :jan_code, :size, :liquid_temperature, :milk, :calorie
  json.url nutrition_url(nutrition, format: :json)
end
