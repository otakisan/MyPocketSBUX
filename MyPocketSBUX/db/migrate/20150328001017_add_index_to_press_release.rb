class AddIndexToPressRelease < ActiveRecord::Migration
  def change
    # 追加
    add_index :press_releases, :press_release_sn
  end
end
