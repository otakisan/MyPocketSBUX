class CreateFoods < ActiveRecord::Migration
  def change
    create_table :foods do |t|
      t.string :name
      t.string :category
      t.string :jan_code
      t.integer :price
      t.string :special
      t.string :notes
      t.string :notification

      t.timestamps
    end
  end
end
