class RemoveCurveAttributesFromLoadProfiles < ActiveRecord::Migration
  def change
    remove_column :load_profiles, :curve_file_name
    remove_column :load_profiles, :curve_content_type
    remove_column :load_profiles, :curve_file_size
    remove_column :load_profiles, :curve_updated_at
  end
end
