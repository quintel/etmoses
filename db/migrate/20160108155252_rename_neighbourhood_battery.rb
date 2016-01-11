class RenameNeighbourhoodBattery < ActiveRecord::Migration
  def up
    tech = Technology.find_by_key('neighbourhood_battery')

    tech.key              = 'congestion_battery'
    tech.behavior         = 'congestion_battery'

    tech.save!
  end

  def down
    tech = Technology.find_by_key('congestion_battery')

    tech.key              = 'neighbourhood_battery'
    tech.behavior         = nil

    tech.save!
  end
end
