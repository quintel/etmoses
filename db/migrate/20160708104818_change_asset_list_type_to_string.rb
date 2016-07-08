class ChangeAssetListTypeToString < ActiveRecord::Migration
  def up
    change_column(:asset_lists, :type, :string, limit: 40, null: false)
  end

  def down
    change_column(:asset_lists, :type, :text)
  end
end
