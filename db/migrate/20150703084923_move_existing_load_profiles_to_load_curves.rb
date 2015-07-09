class MoveExistingLoadProfilesToLoadCurves < ActiveRecord::Migration
  def change
    LoadProfile.all.each do |load_profile|
      begin
        load_curve = ProfileCurve.new
        load_curve.profile_id = load_profile.id
        load_curve.curve = File.new(load_profile.curve.path)
        load_curve.curve_type = 'flex'
        load_curve.save
      rescue Errno::ENOENT
      end
    end
  end
end
