class MoveExistingLoadProfilesToLoadCurves < ActiveRecord::Migration
  def change
    Dir["public/system/load_profiles/curves/000/000/*"].each do |load_profile|
      file = Dir["#{load_profile}/*.csv"].detect{|t| t =~ /original/ }
      id = load_profile.split(/\//).last

      begin
        file_curve = File.new(file)

        load_curve = LoadProfileComponent.new
        load_curve.load_profile_id = id
        load_curve.curve = file_curve
        load_curve.curve_type = 'flex'
        load_curve.save
      rescue StandardError
        puts [file, id].join(" -- ")
      end
    end
  end
end
