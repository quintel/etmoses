module MarketModels
  class Default
    def self.interactions
      JSON.dump([
        { 'stakeholder_from' => 'customer',
          'stakeholder_to'   => 'customer',
          'foundation'       => 'kW_max',
          'tariff'           => '0.5' }
      ])
    end
  end
end
