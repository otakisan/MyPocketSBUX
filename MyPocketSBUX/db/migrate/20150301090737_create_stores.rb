class CreateStores < ActiveRecord::Migration
  def change
    create_table :stores do |t|
      t.integer :store_id
      t.string :name
      t.string :address
      t.string :phone_number
      t.string :holiday
      t.string :access
      t.time :opening_time_weekday
      t.time :closing_time_weekday
      t.time :opening_time_saturday
      t.time :closing_time_saturday
      t.time :opening_time_holiday
      t.time :closing_time_holiday
      t.float :latitude
      t.float :longitude
      t.string :notes
      t.integer :pref_id

      t.timestamps
    end
  end
end
