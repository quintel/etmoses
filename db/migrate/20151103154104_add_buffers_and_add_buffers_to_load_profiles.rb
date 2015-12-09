class AddBuffersAndAddBuffersToLoadProfiles < ActiveRecord::Migration
  def change
    #
    # Space heating
    space_heaters = Technology.where("`key` LIKE 'households_space_heater_heatpump%'")

    buffer_space_heating = Technology.create!(key: 'buffer_space_heating',
                                              name: "Buffer space heating",
                                              composite: true)

    space_heaters.map(&:load_profiles).flatten.uniq.each do |load_profile|
      TechnologyProfile.create!(load_profile: load_profile, technology: buffer_space_heating.key)
    end

    #
    # Water heating
    water_heaters = Technology.where("`key` LIKE 'households_water_heater_heatpump%'")

    buffer_water_heating = Technology.create!(key: 'buffer_water_heating',
                                              name: "Buffer water heating",
                                              composite: true)

    water_heaters.map(&:load_profiles).flatten.uniq.each do |load_profile|
      TechnologyProfile.create!(load_profile: load_profile, technology: buffer_water_heating.key)
    end
  end
end
