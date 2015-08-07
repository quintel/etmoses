module FakeLoadManagement
  def self.topology_graph
    { "name"=>"HV",
      "children"=>[{
        "name"=>"CONGESTED_END_POINT_1",
        "capacity"=>1.0
      }]
    }
  end

  def self.strategies(options = {})
    {
      "storage"                 => (options[:storage] || false),
      "battery_storage"         => (options[:battery_storage] || false),
      "solar_power_to_heat"     => (options[:solar_power_to_heat] || false),
      "solar_power_to_gas"      => (options[:solar_power_to_gas] || false),
      "buffering_electric_car"  => (options[:buffering_electric_car] || false),
      "buffering_space_heating" => (options[:buffering_space_heating] || false),
      "buffering_hot_water"     => (options[:buffering_hot_water] || false),
      "postponing_base_load"    => (options[:postponing_base_load] || false),
      "saving_base_load"        => (options[:saving_base_load] || false),
      "capping_solar_pv"        => (options[:capping_solar_pv] || false),
      'capping_fraction'        => 0.5
    }
  end
end
