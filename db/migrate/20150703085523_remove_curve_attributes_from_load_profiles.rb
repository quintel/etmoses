class RemoveCurveAttributesFromLoadProfiles < ActiveRecord::Migration
  def change
    remove_column :profiles, :curve_file_name
    remove_column :profiles, :curve_content_type
    remove_column :profiles, :curve_file_size
    remove_column :profiles, :curve_updated_at
  end
end
