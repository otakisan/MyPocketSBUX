class CreateTastingLogs < ActiveRecord::Migration
  def change
    create_table :tasting_logs do |t|
      t.string :title
      t.string :tag
      t.datetime :tasting_at
      t.string :detail
      t.references :store, index: true
      t.references :order, index: true

      t.timestamps
    end
  end
end
