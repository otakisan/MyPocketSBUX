class CreateOrderDetails < ActiveRecord::Migration
  def change
    create_table :order_details do |t|
      t.references :order, index: true
      t.string :product_jan_code
      t.string :product_name
      t.string :size
      t.string :hot_or_iced
      t.integer :reusable_cup
      t.string :ticket
      t.integer :tax_exclude_total_price
      t.integer :tax_exclude_custom_price
      t.integer :total_calorie
      t.integer :custom_calorie
      t.string :remarks

      t.timestamps
    end
  end
end
