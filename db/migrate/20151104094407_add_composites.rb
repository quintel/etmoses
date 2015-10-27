class AddComposites < ActiveRecord::Migration
  def change
    space_heaters = Technology.where("`key` LIKE 'households_space_heater_heatpump%'")
    space_composite = Technology.find_by_key("buffer_space_heating")

    space_heaters.each do |tech|
      Composite.create!(technology: tech, composite: space_composite)
    end

    #
    # Water heating
    water_heaters = Technology.where("`key` LIKE 'households_water_heater_heatpump%'")
    water_composite = Technology.find_by_key("buffer_water_heating")

    water_heaters.each do |tech|
      Composite.create!(technology: tech, composite: water_composite)
    end
  end
end
