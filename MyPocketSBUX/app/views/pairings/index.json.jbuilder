json.array!(@pairings) do |pairing|
  json.extract! pairing, :id, :bean_id, :food_id
  json.url pairing_url(pairing, format: :json)
end
