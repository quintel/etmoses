class RemoveP2hProfiles < ActiveRecord::Migration
  def up
    cat = LoadProfileCategory.where(name: 'Power-to-heat').first!
    cat.load_profiles.destroy_all
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
