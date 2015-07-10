class AddNumberOfCurvesToLoadProfileCategories < ActiveRecord::Migration
  def change
    add_column :load_profile_categories, :number_of_curves, :integer, after: :parent_id, default: 1
  end
end
