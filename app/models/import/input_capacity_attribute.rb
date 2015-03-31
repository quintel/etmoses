class Import
  InputCapacityAttribute =
    Attribute.new('capacity', 'input_capacity') do |value, *|
      value * 1000
    end
end
