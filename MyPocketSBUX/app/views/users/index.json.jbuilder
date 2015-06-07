json.array!(@users) do |user|
  json.extract! user, :id, :my_pocket_id, :email_address, :password, :remarks
  json.url user_url(user, format: :json)
end
