class AddLoadProfileCategoriesForComposites < ActiveRecord::Migration
  def up
    # Move the old heat-pump categories to 'deprecated'
    deprecated_id = LoadProfileCategory.find_by_name('Deprecated').id
    heat_pumps    = LoadProfileCategory.find_by_name('Heat pumps')

    heat_pumps.update_attributes!(
      parent_id: deprecated_id,
      name: 'Legacy "stand-alone" heat pumps'
    )

    # Add new categories for the composite profiles.
    parent_id = LoadProfileCategory.find_by_name('Technology profiles').id

    LoadProfileCategory.create!(name: 'Space heating', parent_id: parent_id)
    LoadProfileCategory.create!(name: 'Hot water', parent_id: parent_id)
  end
end
