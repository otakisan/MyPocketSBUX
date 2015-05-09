class CreateTunes < ActiveRecord::Migration
  def change
    create_table :tunes do |t|
      t.string :wrapper_type
      t.string :kind
      t.string :artist_id
      t.string :collection_id
      t.string :track_id
      t.string :artist_name
      t.string :collection_name
      t.string :track_name
      t.string :collection_censored_name
      t.string :track_censored_name
      t.string :artist_view_url
      t.string :collection_view_url
      t.string :track_view_url
      t.string :preview_url
      t.string :artwork_url_30
      t.string :artwork_url_60
      t.string :artwork_url_100
      t.string :collection_price
      t.string :track_price
      t.string :release_date
      t.string :collection_explicitness
      t.string :track_explicitness
      t.string :disc_count
      t.string :disc_number
      t.string :track_count
      t.string :track_number
      t.string :track_time_millis
      t.string :country
      t.string :currency
      t.string :primary_genre_name
      t.string :radio_station_url

      t.timestamps
    end
  end
end
