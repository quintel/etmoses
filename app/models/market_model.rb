class MarketModel < ActiveRecord::Base
  include Privacy

  FOUNDATIONS = %w(
    connections kWh kW_connection kW_max kW_contracted
    flex_realised flex_potential
  )

  PRESENTABLES = %w(stakeholder_from stakeholder_to foundation applied_stakeholder tariff)
  DEFAULT_INTERACTIONS = [{ "stakeholder_from"    => "",
                            "stakeholder_to"      => "",
                            "tariff"              => "",
                            "applied_stakeholder" => "",
                            "price"               => "" }]

  belongs_to :user

  serialize :interactions, JSON
end
