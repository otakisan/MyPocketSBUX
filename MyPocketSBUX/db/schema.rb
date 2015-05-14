# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150513143439) do

  create_table "beans", force: true do |t|
    t.string   "name"
    t.string   "category"
    t.string   "jan_code"
    t.integer  "price"
    t.string   "special"
    t.string   "notes"
    t.string   "notification"
    t.string   "growing_region"
    t.string   "processing_method"
    t.string   "flavor"
    t.string   "body"
    t.string   "acidity"
    t.string   "complementary_flavors"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "drinks", force: true do |t|
    t.string   "name"
    t.string   "category"
    t.string   "jan_code"
    t.integer  "price"
    t.string   "special"
    t.string   "notes"
    t.string   "notification"
    t.string   "size"
    t.string   "milk"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "foods", force: true do |t|
    t.string   "name"
    t.string   "category"
    t.string   "jan_code"
    t.integer  "price"
    t.string   "special"
    t.string   "notes"
    t.string   "notification"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "nutritions", force: true do |t|
    t.string   "jan_code"
    t.string   "size"
    t.string   "liquid_temperature"
    t.string   "milk"
    t.integer  "calorie"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pairings", force: true do |t|
    t.integer  "bean_id"
    t.integer  "food_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "pairings", ["bean_id"], name: "index_pairings_on_bean_id"
  add_index "pairings", ["food_id"], name: "index_pairings_on_food_id"

  create_table "press_releases", force: true do |t|
    t.integer  "fiscal_year"
    t.integer  "press_release_sn"
    t.string   "title"
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "issue_date"
  end

  add_index "press_releases", ["press_release_sn"], name: "index_press_releases_on_press_release_sn"

  create_table "seminars", force: true do |t|
    t.integer  "store_id"
    t.string   "edition"
    t.datetime "start_time"
    t.datetime "end_time"
    t.integer  "day_of_week"
    t.integer  "capacity"
    t.date     "deadline"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "entry_url"
  end

  add_index "seminars", ["store_id"], name: "index_seminars_on_store_id"

  create_table "stores", force: true do |t|
    t.integer  "store_id"
    t.string   "name"
    t.string   "address"
    t.string   "phone_number"
    t.string   "holiday"
    t.string   "access"
    t.time     "opening_time_weekday"
    t.time     "closing_time_weekday"
    t.time     "opening_time_saturday"
    t.time     "closing_time_saturday"
    t.time     "opening_time_holiday"
    t.time     "closing_time_holiday"
    t.float    "latitude"
    t.float    "longitude"
    t.string   "notes"
    t.integer  "pref_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tunes", force: true do |t|
    t.string   "wrapper_type"
    t.string   "kind"
    t.string   "artist_id"
    t.string   "collection_id"
    t.string   "track_id"
    t.string   "artist_name"
    t.string   "collection_name"
    t.string   "track_name"
    t.string   "collection_censored_name"
    t.string   "track_censored_name"
    t.string   "artist_view_url"
    t.string   "collection_view_url"
    t.string   "track_view_url"
    t.string   "preview_url"
    t.string   "artwork_url_30"
    t.string   "artwork_url_60"
    t.string   "artwork_url_100"
    t.string   "collection_price"
    t.string   "track_price"
    t.string   "release_date"
    t.string   "collection_explicitness"
    t.string   "track_explicitness"
    t.string   "disc_count"
    t.string   "disc_number"
    t.string   "track_count"
    t.string   "track_number"
    t.string   "track_time_millis"
    t.string   "country"
    t.string   "currency"
    t.string   "primary_genre_name"
    t.string   "radio_station_url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
