json.array!(@tasting_logs) do |tasting_log|
  json.extract! tasting_log, :id, :title, :tag, :tasting_at, :detail, :store_id, :order_id, :my_pocket_id, :created_at, :updated_at
  json.url tasting_log_url(tasting_log, format: :json)
end
