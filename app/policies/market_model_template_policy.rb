class MarketModelTemplatePolicy < ApplicationPolicy
  include PrivatePolicy
  include FeatureScope

  def attributes
    [:name, :public, :interactions]
  end

  def clone?
    true
  end
end
