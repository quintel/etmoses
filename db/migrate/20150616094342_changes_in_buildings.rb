class ChangesInBuildings < ActiveRecord::Migration
  def change
    Technology.create!(key: 'base_load_buildings', name: 'Buildings')
    LoadProfile.where("`key` REGEXP 'edsn_e(3|4).+'").map do |load_profile|
      TechnologyProfile.create!(load_profile_id: load_profile.id,
                                technology: 'base_load_buildings')
    end
  end
end
