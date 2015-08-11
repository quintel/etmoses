class AddKeyToLoadProfileCategories < ActiveRecord::Migration
  def change
    add_column :load_profile_categories, :key, :string, after: :name
  end
end
