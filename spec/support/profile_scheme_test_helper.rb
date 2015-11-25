module ProfileSchemeTestHelper
  def self.minimized_technology_distribution
    [{
      "name"=>"Residential PV panel",
      "type"=>"households_solar_pv_solar_radiation",
      "profile"=>"solar_pv_zwolle",
      "capacity"=>"-1.5",
      "demand" => nil,
      "units"=>"1.0",
      "node"=>"lv1",
      "concurrency" => "max"
    },
    {
      "name"=>"Residential PV panel",
      "type"=>"households_solar_pv_solar_radiation",
      "profile"=>"solar_pv_ameland",
      "capacity"=>"-1.5",
      "demand" => nil,
      "units"=>"1.0",
      "node"=>"lv1",
      "concurrency" => "max"
    },
    {
      "name"=>"Residential PV panel",
      "type"=>"households_solar_pv_solar_radiation",
      "profile"=>"solar_pv_zwolle",
      "capacity"=>"-1.5",
      "demand" => nil,
      "units"=>"1.0",
      "node"=>"lv2",
      "concurrency" => "max"
    },
    {
      "name"=>"Residential PV panel",
      "type"=>"households_solar_pv_solar_radiation",
      "profile"=>"solar_pv_ameland",
      "capacity"=>"-1.5",
      "demand" => nil,
      "units"=>"1.0",
      "node"=>"lv2",
      "concurrency" => "max"
    }]
  end

  def self.minimized_technology_distribution_buffers
    [{
      "node"        => "lv1",
      "buffer"      => "buffer_1",
      "name"        => "Space heater 1",
      "type"        => "households_space_heater_heatpump_ground_water_electricity",
      "concurrency" => "max",
      "capacity"    => "-1.5",
      "units"       => "1",
      "composite"   => false
    },
    {
      "node"        => "lv1",
      "buffer"      => "buffer_1",
      "name"        => "Space heater 2",
      "type"        => "households_space_heater_heatpump_air_water_electricity",
      "concurrency" => "max",
      "capacity"    => "-1.5",
      "units"       => "1",
      "composite"   => false
    },
    {
      "node"            => "lv1",
      "profile"         => "buffer_1_profile",
      "name"            => "Buffer",
      "composite_value" => "buffer_1",
      "type"            => "buffer_space_heating",
      "capacity"        => "-1.5",
      "concurrency"     => "max",
      "units"           => "2",
      "composite"       => true,
      "buffer"          => nil
    },
    {
      "node"        => "lv1",
      "buffer"      => "buffer_2",
      "name"        => "Space heater 3",
      "type"        => "households_space_heater_heatpump_ground_water_electricity",
      "concurrency" => "max",
      "capacity"    => "-1.5",
      "units"       => "1",
      "composite"   => false
    },
    {
      "node"        => "lv1",
      "buffer"      => "buffer_2",
      "name"        => "Space heater 4",
      "type"        => "households_space_heater_heatpump_air_water_electricity",
      "concurrency" => "max",
      "capacity"    => "-1.5",
      "units"       => "1",
      "composite"   => false
    },
    {
      "node"            => "lv1",
      "profile"         => "buffer_2_profile",
      "name"            => "Buffer",
      "composite_value" => "buffer_2",
      "type"            => "buffer_space_heating",
      "capacity"        => "-1.5",
      "concurrency"     => "max",
      "units"           => "2",
      "composite"       => true,
      "buffer"          => nil
    }]
  end

  def self.technology_distribution_buffers
    [{
      "node"        => "lv2",
      "buffer"      => "buffer_1",
      "name"        => "Space heater 1",
      "type"        => "households_space_heater_heatpump_ground_water_electricity",
      "concurrency" => "min",
      "capacity"    => "-1.5",
      "units"       => "10.0",
      "composite"   => false
    },
    {
      "node"        => "lv2",
      "buffer"      => "buffer_1",
      "name"        => "Space heater 2",
      "type"        => "households_space_heater_heatpump_air_water_electricity",
      "concurrency" => "min",
      "capacity"    => "-1.5",
      "units"       => "10.0",
      "composite"   => false
    },
    {
      "name"=>"Residential PV panel",
      "type"=>"households_solar_pv_solar_radiation",
      "profile"=>"solar_pv_zwolle",
      "capacity"=>"-1.5",
      "demand" => nil,
      "units"=>"1.0",
      "node"=>"lv2",
      "concurrency" => "min"
    },
    {
      "node"            => "lv2",
      "profile"         => "buffer_1_profile",
      "name"            => "Buffer",
      "composite_value" => "buffer_1",
      "type"            => "buffer_space_heating",
      "capacity"        => "-1.5",
      "concurrency"     => "min",
      "units"           => "10.0",
      "composite"       => true,
      "buffer"          => nil
    }]
  end

  def self.technology_distribution
    [{
      "name"=>"Residential PV panel",
      "type"=>"households_solar_pv_solar_radiation",
      "profile"=>"solar_pv_zwolle",
      "capacity"=>"-1.5",
      "units"=>"1.0",
      "node"=>"lv1",
      "concurrency" => "min"
    },
    {
      "name"=>"Residential PV panel",
      "type"=>"households_solar_pv_solar_radiation",
      "profile"=>"solar_pv_zwolle",
      "capacity"=>"-1.5",
      "units"=>"1.0",
      "node"=>"lv2",
      "concurrency" => "min"
    }]
  end

  def self.basic_houses(units = '2.0')
    [{ "name"=>"Household",
       "type"=>"base_load",
       "demand"=>"5",
       "units"=>units,
       "concurrency" => 'min' }]
  end

  def self.basic_edsn_houses(units = '2.0')
    [{ "name"=>"Household",
      "type"=>"base_load_edsn",
      "demand"=>"5",
      "units"=>units,
      "concurrency" => 'min' }]
  end

  def self.load
    JSON.parse(File.read("#{Rails.root}/spec/fixtures/data/testing_ground_min.txt"))
  end
end
