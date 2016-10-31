class MarketModel < ActiveRecord::Base
  include MarketModelInteractions

  belongs_to :testing_ground
  belongs_to :market_model_template
end
