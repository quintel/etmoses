class RemoveP2hProfiles < ActiveRecord::Migration
  def up
    LoadProfile.where('`key` LIKE "p2h_use_profile%"').destroy_all
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
