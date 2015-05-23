json.array!(@tasting_logs) do |tasting_log|
  json.extract! tasting_log, :id, :title, :tag, :tasting_at, :detail, :store_id, :order_id
  json.url tasting_log_url(tasting_log, format: :json)
end
