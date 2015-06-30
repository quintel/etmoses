class MarketModel < ActiveRecord::Base
  BASES = ["kWh", "kW_connection", "kW_max", "kW_contracted", "kW_flex"]
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
