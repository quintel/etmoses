class MarketModelTemplatePolicy < ApplicationPolicy
  include PrivatePolicy
  include FeatureScope

  def clone?
    true
  end
end
