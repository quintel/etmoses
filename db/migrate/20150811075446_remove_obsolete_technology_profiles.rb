class RemoveObsoleteTechnologyProfiles < ActiveRecord::Migration
  def change
    TechnologyProfile.all.map do |tp|
      tp.delete unless LoadProfile.find_by_id(tp.load_profile_id)
    end
  end
end
