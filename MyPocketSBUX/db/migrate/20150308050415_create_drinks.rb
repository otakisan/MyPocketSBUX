class CreateDrinks < ActiveRecord::Migration
  def change
    create_table :drinks do |t|
      t.string :name
      t.string :category
      t.string :jan_code
      t.integer :price
      t.string :special
      t.string :notes
      t.string :notification
      t.string :size
      t.string :milk

      t.timestamps
    end
  end
end
