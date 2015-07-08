class UpdateLoadCurves < ActiveRecord::Migration
  def change
    rename_column :load_curves, :load_profile_id, :profile_id
    rename_table :load_curves, :profile_curves
  end
end
