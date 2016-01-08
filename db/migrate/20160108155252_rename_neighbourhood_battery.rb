class RenameNeighbourhoodBattery < ActiveRecord::Migration
  def up
    tech = Technology.find_by_key('neighbourhood_battery')

    tech.key              = 'congestion_battery'
    tech.behavior         = 'congestion_battery'
    tech.default_capacity = 10.0
    tech.default_volume   = 100.0

    tech.save!
  end

  def down
    tech = Technology.find_by_key('congestion_battery')

    tech.key              = 'neighbourhood_battery'
    tech.behavior         = nil
    tech.default_capacity = nil
    tech.default_volume   = nil

    tech.save!
  end
end
