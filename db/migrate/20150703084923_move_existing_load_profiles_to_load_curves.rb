class MoveExistingLoadProfilesToLoadCurves < ActiveRecord::Migration
  def change
    LoadProfile.all.each do |load_profile|
      begin
        load_curve = LoadCurve.new
        load_curve.load_profile_id = load_profile.id
        load_curve.curve = File.new(load_profile.curve.path)
        load_curve.curve_type = 'Flexible'
        load_curve.save
      rescue Errno::ENOENT
      end
    end
  end
end
