module TestingGroundsControllerTest
  def self.create_hash
    {
      "testing_ground" => {
        "name"=>"",
        "parent_scenario_id"=>"",
        "scenario_id"=>"",
        "technologies"=>"---\r\n- name: Heat Pump Type 1\r\n  capacity: 1.5\r\n  units: 2\r\n  type: households_space_heater_heatpump_air_water_electricity\r\n- name: Heat Pump Type 2\r\n  capacity: 1.5\r\n  type: households_space_heater_heatpump_ground_water_electricity\r\n- name: Solar Panel\r\n  capacity: -1.5\r\n  units: 200\r\n  type: households_solar_pv_solar_radiation\r\n",
        "topology_attributes"=>{"graph"=>"---\r\nname: HV Network\r\nchildren:\r\n- name: MV Network\r\n  children:\r\n  - name: \"LV #1\"\r\n  - name: \"LV #2\"\r\n  - name: \"LV #3\"\r\n"},
        "technology_profile"=>"---\r\n'LV #1':\r\n- name: Heat Pump Type 1\r\n  capacity: 1.5\r\n  units: 1\r\n  type: households_space_heater_heatpump_air_water_electricity\r\n  profile: hp_space_heating_10kw_75m2_100liter\r\n- name: Heat Pump Type 2\r\n  capacity: 1.5\r\n  type: households_space_heater_heatpump_ground_water_electricity\r\n  profile: hp_space_heating_10kw_75m2_100liter\r\n  units: 1\r\n- name: Solar Panel\r\n  capacity: -1.5\r\n  units: 67\r\n  type: households_solar_pv_solar_radiation\r\n  profile: solar_pv_zwolle\r\n'LV #2':\r\n- name: Heat Pump Type 1\r\n  capacity: 1.5\r\n  units: 1\r\n  type: households_space_heater_heatpump_air_water_electricity\r\n  profile: hp_space_heating_10kw_75m2_100liter\r\n- name: Solar Panel\r\n  capacity: -1.5\r\n  units: 67\r\n  type: households_solar_pv_solar_radiation\r\n  profile: solar_pv_zwolle\r\n'LV #3':\r\n- name: Solar Panel\r\n  capacity: -1.5\r\n  units: 66\r\n  type: households_solar_pv_solar_radiation\r\n  profile: solar_pv_zwolle\r\n"
        },
        "js"=>{"technologies_as"=>"yaml"},
        "differentiation"=>"min",
        "commit"=>"Create Testing ground"
      }
  end
end
