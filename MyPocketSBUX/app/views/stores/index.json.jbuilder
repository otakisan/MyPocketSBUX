json.array!(@stores) do |store|
  json.extract! store, :id, :store_id, :name, :address, :phone_number, :holiday, :access, :opening_time_weekday, :closing_time_weekday, :opening_time_saturday, :closing_time_saturday, :opening_time_holiday, :closing_time_holiday, :latitude, :longitude, :notes, :pref_id
  json.url store_url(store, format: :json)
end
