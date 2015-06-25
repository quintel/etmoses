class MarketModel < ActiveRecord::Base
  BASES = ["kWh", "kW_connection", "kW_max", "kW_contracted", "kW_flex"]

  belongs_to :user

  serialize :interactions

  def interactions
    JSON.parse(super)
  end
end
