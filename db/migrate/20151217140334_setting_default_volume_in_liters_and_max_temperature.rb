class SettingDefaultVolumeInLitersAndMaxTemperature < ActiveRecord::Migration
  def change
    bsh = Technology.find_by(key: "buffer_space_heating")
    bsh.update_attributes(default_volume_in_liters: 100, max_bufferable_temperature: 40)

    bwh = Technology.find_by(key: "buffer_water_heating")
    bwh.update_attributes(default_volume_in_liters: 100, max_bufferable_temperature: 50)
  end
end
