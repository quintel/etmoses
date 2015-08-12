module Market::Measures
  # A sum of all consumption on the node, in kWh.
  KwhConsumed = Kwh.new { |amount| amount > 0 ? amount : 0 }
end
