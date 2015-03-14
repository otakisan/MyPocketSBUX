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

ActiveRecord::Schema.define(version: 20150314093113) do

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

  create_table "nutritions", force: true do |t|
    t.string   "jan_code"
    t.string   "size"
    t.string   "liquid_temperature"
    t.string   "milk"
    t.integer  "calorie"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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

end
