json.array!(@tunes) do |tune|
  json.extract! tune, :id, :wrapper_type, :kind, :artist_id, :collection_id, :track_id, :artist_name, :collection_name, :track_name, :collection_censored_name, :track_censored_name, :artist_view_url, :collection_view_url, :track_view_url, :preview_url, :artwork_url_30, :artwork_url_60, :artwork_url_100, :collection_price, :track_price, :release_date, :collection_explicitness, :track_explicitness, :disc_count, :disc_number, :track_count, :track_number, :track_time_millis, :country, :currency, :primary_genre_name, :radio_station_url
  json.url tune_url(tune, format: :json)
end
