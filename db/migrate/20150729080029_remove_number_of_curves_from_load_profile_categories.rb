class RemoveNumberOfCurvesFromLoadProfileCategories < ActiveRecord::Migration
  def change
    remove_column :load_profile_categories, :number_of_curves
  end
end
