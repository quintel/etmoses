class MarketModel < ActiveRecord::Base
  include Privacy

  FOUNDATIONS = Market::Builder::MEASURES.keys

  PRESENTABLES = %w(stakeholder_from stakeholder_to foundation applied_stakeholder tariff)
  DEFAULT_INTERACTIONS = [{ "stakeholder_from"    => "",
                            "stakeholder_to"      => "",
                            "tariff"              => "",
                            "tariff_type"         => "fixed",
                            "applied_stakeholder" => "",
                            "price"               => "" }]

  belongs_to :user

  serialize :interactions, JSON
end
