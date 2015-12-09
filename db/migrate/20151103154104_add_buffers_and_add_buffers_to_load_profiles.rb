class AddBuffersAndAddBuffersToLoadProfiles < ActiveRecord::Migration
  def change
    Technology.reset_column_information

    # Space heating
    Technology.create!(
      key: 'buffer_space_heating',
      name: "Buffer space heating",
      composite: true
    )

    # Water heating
    Technology.create!(
      key: 'buffer_water_heating',
      name: "Buffer water heating",
      composite: true
    )
  end
end
