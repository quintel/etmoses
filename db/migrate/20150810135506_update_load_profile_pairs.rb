class UpdateLoadProfilePairs < ActiveRecord::Migration
  def change
    an_base_loads = LoadProfile.where("`key` REGEXP '(in)?flex'")

    grouped = an_base_loads.group_by{|l| l.key.gsub(/_(in)?flex/, '') }

    grouped.each_pair do |key, profiles|
      primary_profile = profiles.first
      profiles.each do |profile|
        profile.load_profile_components.each do |lpc|
          lpc.update_attribute(:load_profile_id, primary_profile.id)
        end
      end
      profiles.last.delete
    end
  end
end
