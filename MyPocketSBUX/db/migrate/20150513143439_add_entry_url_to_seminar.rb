class AddEntryUrlToSeminar < ActiveRecord::Migration
  def change
    add_column :seminars, :entry_url, :string
  end
end
