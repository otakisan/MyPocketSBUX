class CreateSeminars < ActiveRecord::Migration
  def change
    create_table :seminars do |t|
      t.references :store, index: true
      t.string :edition
      t.time :start_time
      t.time :end_time
      t.integer :day_of_week
      t.integer :capacity
      t.date :deadline
      t.string :status

      t.timestamps
    end
  end
end
