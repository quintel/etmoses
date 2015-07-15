class MarketModel < ActiveRecord::Base
  include Privacy

  FOUNDATIONS = ["kWh", "kW_connection", "kW_max", "kW_contracted", "kW_flex"]
  MEASURES = ['per_hh', 'endpoints_stakeholder_total']
  DEFAULT_INTERACTIONS = JSON.dump([{ "stakeholder_from" => "",
                                      "stakeholder_to"   => "",
                                      "tariff"           => "",
                                      "price"            => "" }])

  belongs_to :user

  serialize :interactions

  def interactions
    JSON.parse(super)
  end
end
