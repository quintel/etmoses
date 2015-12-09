class AddHwhP2hToBufferWaterHeating < ActiveRecord::Migration
  def change
    buffer_water = Technology.find_by_key("buffer_water_heating")

    keys = %w(
      households_water_heater_network_gas
      households_water_heater_combined_network_gas
      households_flexibility_p2h_electricity
    )

    Technology.where(key: keys).each do |tech|
      Composite.create!(technology_id: tech.id, composite_id: buffer_water.id)
    end
  end
end
