class MarketModelPolicy < ApplicationPolicy
  def update?
    super || record.testing_ground.user == user
  end

  def clone?
    true
  end

  alias_method :replace?, :clone?
end
