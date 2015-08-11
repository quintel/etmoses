class RenameUsedFlexProfilesInTestingGrounds < ActiveRecord::Migration
  def change
    TestingGround.all.each do |testing_ground|
      testing_ground.technology_profile.each_tech do |tech|
        if tech.profile.present? && load_profile = LoadProfile.where(key: tech.profile).first
          tech.profile = load_profile.id
        end
      end

      testing_ground.save
    end
  end
end
