class UpdateHeatpumpDefaults < ActiveRecord::Migration
  TECHS = {
    households_space_heater_heatpump_air_water_electricity: {
      capacity: 10.0, volume: 2.32, multi: 4.5
    },
    households_space_heater_heatpump_ground_water_electricity: {
      capacity: 10.0, volume: 2.32, multi: 4.8
    },
    households_water_heater_heatpump_air_water_electricity: {
      capacity: 10.0, volume: 5.8, multi: 3.0
    },
    households_water_heater_heatpump_ground_water_electricity: {
      capacity: 10.0, volume: 5.8, multi: 3.0
    }
  }

  def up
    TECHS.each do |key, attrs|
      technology = Technology.find_by_key(key)

      technology.default_capacity = attrs[:capacity] / attrs[:multi]
      technology.default_volume   = attrs[:volume] / attrs[:multi]

      technology.save(validate: false)
    end
  end

  def down
    TECHS.each do |key, attrs|
      technology = Technology.find_by_key(key)

      technology.default_capacity = attrs[:capacity]
      technology.default_volume   = attrs[:volume]

      technology.save(validate: false)
    end
  end
end
