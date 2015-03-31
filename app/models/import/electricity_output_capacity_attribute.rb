class Import
  ElectricityOutputCapacityAttribute =
    Attribute.new('capacity', 'electricity_output_capacity') do |value, *|
      value * 1000
    end
end
