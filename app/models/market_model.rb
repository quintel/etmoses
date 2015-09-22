class MarketModel < ActiveRecord::Base
  include Privacy

  FOUNDATIONS = Market::Builder::MEASURES.keys

  PRESENTABLES = %w(stakeholder_from stakeholder_to applied_stakeholder foundation tariff)
  DEFAULT_INTERACTIONS = [{ "stakeholder_from"    => "",
                            "stakeholder_to"      => "",
                            "tariff"              => "",
                            "tariff_type"         => "fixed",
                            "applied_stakeholder" => "",
                            "price"               => "" }]

  belongs_to :user

  serialize :interactions, JSON

  validates :name, presence: true
end
