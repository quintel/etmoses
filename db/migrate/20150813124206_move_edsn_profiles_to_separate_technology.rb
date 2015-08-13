class MoveEdsnProfilesToSeparateTechnology < ActiveRecord::Migration
  def change
    load_profiles = LoadProfile.where("`key` REGEXP '^edsn_e[1-2]'")

    load_profiles.each do |load_profile|
      load_profile.technology_profiles.each do |tech_profile|
        tech_profile.update_attribute(:technology, "base_load_edsn")
      end
    end
  end
end
