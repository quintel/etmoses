class Import
  HeatCapacityAttribute = Attribute.new(
    'heat_capacity',
    'heat_output_capacity') do |value, _|
      value * 1000 # MW to kW
    end
end
