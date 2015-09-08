class MarketModel < ActiveRecord::Base
  include Privacy

  FOUNDATIONS = %w(connections kWh kW_connection kW_max kW_contracted kW_flex)
  PRESENTABLES = %w(stakeholder_from stakeholder_to foundation applied_stakeholder tariff)
  DEFAULT_INTERACTIONS = [{ "stakeholder_from"    => "",
                            "stakeholder_to"      => "",
                            "tariff"              => "",
                            "applied_stakeholder" => "",
                            "price"               => "" }]

  belongs_to :user

  serialize :interactions, JSON
end
