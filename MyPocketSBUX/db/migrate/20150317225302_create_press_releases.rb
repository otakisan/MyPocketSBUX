class CreatePressReleases < ActiveRecord::Migration
  def change
    create_table :press_releases do |t|
      t.integer :fiscal_year
      t.integer :press_release_sn
      t.string :title
      t.string :url

      t.timestamps
    end
  end
end
