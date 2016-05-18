class Import
  # Heat production is the capacity of the heat source times the amount of
  # units. This will leave you with a production in MW (* 1000 = kW).
  HeatProductionAttribute =
    Attribute.new('heat_production', 'heat_production') do |value, data|
      data["heat_output_capacity"]["future"] *
      data["number_of_units"]["future"] *
      1000
    end
end

