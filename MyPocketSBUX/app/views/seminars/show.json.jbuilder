json.extract! @seminar, :id, :store_id, :edition, :start_time, :end_time, :day_of_week, :capacity, :deadline, :status, :created_at, :updated_at
json.store do
  json.name @seminar.store.name
  json.store_id @seminar.store.store_id
end

