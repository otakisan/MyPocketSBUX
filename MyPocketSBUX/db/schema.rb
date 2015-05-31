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

ActiveRecord::Schema.define(version: 20150531051411) do

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

  create_table "order_details", force: true do |t|
    t.integer  "order_id"
    t.string   "product_jan_code"
    t.string   "product_name"
    t.string   "size"
    t.string   "hot_or_iced"
    t.integer  "reusable_cup"
    t.string   "ticket"
    t.integer  "tax_exclude_total_price"
    t.integer  "tax_exclude_custom_price"
    t.integer  "total_calorie"
    t.integer  "custom_calorie"
    t.string   "remarks"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "order_details", ["order_id"], name: "index_order_details_on_order_id"

  create_table "orders", force: true do |t|
    t.integer  "store_id"
    t.integer  "tax_excluded_total_price"
    t.integer  "tax_included_total_price"
    t.string   "remarks"
    t.string   "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "orders", ["store_id"], name: "index_orders_on_store_id"

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

  create_table "product_ingredients", force: true do |t|
    t.integer  "order_detail_id"
    t.integer  "is_custom"
    t.string   "name"
    t.string   "milk_type"
    t.integer  "unit_calorie"
    t.integer  "unit_price"
    t.integer  "quantity"
    t.integer  "enabled"
    t.integer  "quantity_type"
    t.string   "remarks"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "product_ingredients", ["order_detail_id"], name: "index_product_ingredients_on_order_detail_id"

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

  create_table "tasting_logs", force: true do |t|
    t.string   "title"
    t.string   "tag"
    t.datetime "tasting_at"
    t.string   "detail"
    t.integer  "store_id"
    t.integer  "order_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tasting_logs", ["order_id"], name: "index_tasting_logs_on_order_id"
  add_index "tasting_logs", ["store_id"], name: "index_tasting_logs_on_store_id"

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
