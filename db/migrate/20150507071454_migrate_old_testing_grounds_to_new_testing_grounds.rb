class MigrateOldTestingGroundsToNewTestingGrounds < ActiveRecord::Migration
  def change
    change_column :testing_grounds, :technology_profile, :text, limit: 16777215

    TestingGround.all.each do |testing_ground|
      testing_ground.update_column(:technology_profile, testing_ground.technologies)
      testing_ground.update_column(:technologies, [])
    end
  end
end
