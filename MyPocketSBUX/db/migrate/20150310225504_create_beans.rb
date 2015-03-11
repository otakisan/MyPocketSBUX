class CreateBeans < ActiveRecord::Migration
  def change
    create_table :beans do |t|
      t.string :name
      t.string :category
      t.string :jan_code
      t.integer :price
      t.string :special
      t.string :notes
      t.string :notification
      t.string :growing_region
      t.string :processing_method
      t.string :flavor
      t.string :body
      t.string :acidity
      t.string :complementary_flavors

      t.timestamps
    end
  end
end
