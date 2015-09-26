class AddCopImportableAttribute < ActiveRecord::Migration
  TECHS = %w(
    households_space_heater_heatpump_air_water_electricity
    households_space_heater_heatpump_ground_water_electricity
    households_water_heater_heatpump_air_water_electricity
    households_water_heater_heatpump_ground_water_electricity
  )

  def up
    Technology.where(key: TECHS).each do |tech|
      tech.importable_attributes.create!(name: 'coefficient_of_performance')
    end
  end

  def down
    ImportableAttribute.where(name: 'coefficient_of_performance').destroy
  end
end
