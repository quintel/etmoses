module Market::Measures
  # A sum of all production on the node, in kWh.
  KwhProduced = Kwh.new { |amount| amount < 0 ? amount.abs : 0 }
end
