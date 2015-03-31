class CreateTechnologies < ActiveRecord::Migration
  def up
    create_table :technologies do |t|
      t.string :key,         limit: 100, null: false
      t.string :name,        limit: 100

      t.string :import_from, limit: 50
      t.string :export_to,   limit: 100

      t.index :key, unique: true
    end

    Technology.create!(
      key:         'households_solar_pv_solar_radiation',
      name:        'Residential PV panel',
      import_from: 'electricity_output_capacity',
      export_to:   'households_solar_pv_solar_radiation_market_penetration'
    )

    Technology.create!(
      key:         'households_space_heater_heatpump_air_water_electricity',
      name:        'Heat pump for space heating (air)',
      import_from: 'input_capacity',
      export_to:   'households_space_heater_heatpump_air_water_electricity_share'
    )

    Technology.create!(
      key:         'households_space_heater_heatpump_ground_water_electricity',
      name:        'Heat pump for space heating (ground)',
      import_from: 'input_capacity',
      export_to:   'households_space_heater_heatpump_ground_water_electricity_share'
    )

    Technology.create!(
      key:         'households_water_heater_heatpump_air_water_electricity',
      name:        'Heat pump for hot water (air)',
      import_from: 'input_capacity',
      export_to:   'households_water_heater_heatpump_air_water_electricity_share'
    )

    Technology.create!(
      key:         'households_water_heater_heatpump_ground_water_electricity',
      name:        'Heat pump for hot water (ground)',
      import_from: 'input_capacity',
      export_to:   'households_water_heater_heatpump_ground_water_electricity_share'
    )

    Technology.create!(
      key:         'transport_car_using_electricity',
      name:        'Electric car',
      import_from: 'input_capacity',
      export_to:   'transport_car_using_electricity_share'
    )
  end

  def down
    drop_table :technologies
  end
end
