class CreateNutritions < ActiveRecord::Migration
  def change
    create_table :nutritions do |t|
      t.string :jan_code
      t.string :size
      t.string :liquid_temperature
      t.string :milk
      t.integer :calorie

      t.timestamps
    end
  end
end
