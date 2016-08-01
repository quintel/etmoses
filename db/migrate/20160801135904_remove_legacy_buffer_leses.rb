class RemoveLegacyBufferLeses < ActiveRecord::Migration
  HEAT_PUMPS = %w(
    households_space_heater_heatpump_air_water_electricity
    households_space_heater_heatpump_ground_water_electricity
    households_water_heater_heatpump_air_water_electricity
    households_water_heater_heatpump_ground_water_electricity
  )

  def up
    TestingGround.find_each do |les|
      les.technology_profile.each_tech do |tech|
        if HEAT_PUMPS.include?(tech.type) && tech.buffer.blank?
          puts "Removing LES: #{ les.name } (#{ les.id })"
          les.destroy!
          break
        end
      end
    end
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
