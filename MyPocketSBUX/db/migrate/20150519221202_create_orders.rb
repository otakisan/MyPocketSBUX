class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.references :store, index: true
      t.integer :tax_excluded_total_price
      t.integer :tax_included_total_price
      t.string :remarks
      t.string :notes

      t.timestamps
    end
  end
end
