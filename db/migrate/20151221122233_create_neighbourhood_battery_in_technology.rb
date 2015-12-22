class CreateNeighbourhoodBatteryInTechnology < ActiveRecord::Migration
  def change
    Technology.create!(
      key: 'neighbourhood_battery',
      name: "Neighbourhood battery",
      carrier: "electricity",
      behavior: nil
    )
  end
end
