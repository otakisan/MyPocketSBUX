class CreateProductIngredients < ActiveRecord::Migration
  def change
    create_table :product_ingredients do |t|
      t.references :order_detail, index: true
      t.integer :is_custom
      t.string :name
      t.string :milk_type
      t.integer :unit_calorie
      t.integer :unit_price
      t.integer :quantity
      t.integer :enabled
      t.integer :quantity_type
      t.string :remarks

      t.timestamps
    end
  end
end
