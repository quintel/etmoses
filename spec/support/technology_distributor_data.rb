module TechnologyDistributorData
  def basic_technologies(units = '2.0')
    [{ "name"=>"Residential PV panel",
      "type"=>"households_solar_pv_solar_radiation",
      "capacity"=>"-1.5",
      "units"=>units }]
  end

  def composite_technologies(units = '2.0')
    [
      {
        "name"      => "Buffer space heating",
        "type"      => "buffer_space_heating",
        "capacity"  => "5.0",
        "units"     => units,
        "composite" => true,
        "includes"  => [ "households_space_heater_heatpump_ground_water_electricity" ]
      },
      {
        "name"     => "Heat pump for space heating (ground)",
        "type"     => "households_space_heater_heatpump_ground_water_electricity",
        "capacity" => "2.0",
        "units"    => units
      }
    ]
  end
end
