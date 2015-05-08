def testing_ground_technologies_without_profiles
  [ { "type"=>"households_solar_pv_solar_radiation",
      "name"=>"Residential PV panel",
      "units"=>200,
      "capacity"=>1.5 },
    { "type"=>"households_space_heater_heatpump_air_water_electricity",
      "name"=>"Heat pump for space heating (air)",
      "units"=>2,
      "capacity"=>10.0 },
    { "type"=>"households_space_heater_heatpump_ground_water_electricity",
      "name"=>"Heat pump for space heating (ground)",
      "units"=>2,
      "capacity"=>10.0 },
    { "type"=>"households_water_heater_heatpump_air_water_electricity",
      "name"=>"Heat pump for hot water (air)",
      "units"=>2,
      "capacity"=>10.0},
   {  "type"=>"households_water_heater_heatpump_ground_water_electricity",
      "name"=>"Heat pump for hot water (ground)",
      "units"=>2,
      "capacity"=>10.0},
   {  "type"=>"transport_car_using_electricity",
      "name"=>"Electric car",
      "units"=>1,
      "capacity"=>3.7 },
   {  "type"=>"transport_car_using_electricity",
      "name"=>nil,
      "units" => 1.0,
      "capacity"=>3.7 }
  ]
end

def testing_ground_technologies_without_profiles_subset
  [ { "type"=>"households_solar_pv_solar_radiation",
      "name"=>"Residential PV panel",
      "units"=>4,
      "capacity"=>1.5 },
    { "type"=>"transport_car_using_electricity",
      "name"=>"Electric car",
      "units"=>4,
      "capacity"=>1.5 }
  ]
end
