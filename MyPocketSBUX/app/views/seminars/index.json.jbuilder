json.array!(@seminars) do |seminar|
  json.extract! seminar, :id, :store_id, :edition, :start_time, :end_time, :day_of_week, :capacity, :deadline, :status, :entry_url, :created_at, :updated_at
  json.store do 
    json.name seminar.store.name
    json.store_id seminar.store.store_id
  end
  json.url seminar_url(seminar, format: :json)
end
