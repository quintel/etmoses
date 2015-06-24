class AssignBehaviorsToPumpsAndSolar < ActiveRecord::Migration
  BEHAVIORS = {
    'households_solar_pv_solar_radiation' => 'conserving',
    'households_space_heater_heatpump_air_water_electricity' => 'preemptive',
    'households_space_heater_heatpump_ground_water_electricity' => 'preemptive',
    'households_water_heater_heatpump_air_water_electricity' => 'preemptive',
    'households_water_heater_heatpump_ground_water_electricity' => 'preemptive'
  }.freeze

  def up
    BEHAVIORS.each do |key, behavior|
      Technology.by_key(key).update_attributes!(behavior: behavior)
    end
  end

  def down
    BEHAVIORS.keys.each do |key|
      Technology.by_key(key).update_attributes!(behavior: nil)
    end
  end
end
