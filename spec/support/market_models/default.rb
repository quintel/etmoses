module MarketModels
  class Default
    def self.interactions
      [{ 'stakeholder_from' => 'customer',
         'stakeholder_to'   => 'customer',
         'foundation'       => 'kWh',
         'tariff'           => '0.5' }]
    end
  end
end
