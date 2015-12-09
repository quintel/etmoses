class SetAllProfilesAsPriceCurves < ActiveRecord::Migration
  def change
    Profile.update_all(type: "PriceCurve")
  end
end
