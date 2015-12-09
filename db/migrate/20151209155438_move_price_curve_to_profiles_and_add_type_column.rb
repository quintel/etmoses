class MovePriceCurveToProfilesAndAddTypeColumn < ActiveRecord::Migration
  def change
    rename_table :price_curves, :profiles

    add_column :profiles, :type, :string, after: :id
  end
end
