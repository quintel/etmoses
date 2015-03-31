class Import
  DemandAttribute =
    Attribute.new('demand', 'demand') do |value, data, attribute|
      units = attribute.future(data, 'number_of_units')

      # Convert the value from MJ to kWh (1 MWh = 3600 MJ).
      units.zero? ? 0.0 : value * (1.0 / 3.6) / units
    end
end
