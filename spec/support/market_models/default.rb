module MarketModels
  class Default
    def self.interactions
      [{ 'stakeholder_from'    => 'customer',
         'stakeholder_to'      => 'customer',
         'foundation'          => 'kwh_consumed',
         'tariff'              => '0.5',
         'applied_stakeholder' => 'customer'
      }]
    end

    def self.advanced
      [{ 'stakeholder_from'    => 'customer',
         'stakeholder_to'      => 'supplier',
         'foundation'          => 'kwh_consumed',
         'tariff'              => '0.5',
         'applied_stakeholder' => 'customer' },
       { 'stakeholder_from'    => 'system operator',
         'stakeholder_to'      => 'government',
         'foundation'          => 'kwh_consumed',
         'tariff'              => '0.5',
         'applied_stakeholder' => 'customer'
        }
      ]
    end
  end
end
