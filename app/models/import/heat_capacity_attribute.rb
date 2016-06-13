class Import
  HeatCapacityAttribute = Attribute.new(
    'heat_capacity',
    'heat_output_capacity') do |value, _|
      value.round(5)
    end
end
