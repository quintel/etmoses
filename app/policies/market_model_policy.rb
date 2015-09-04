class MarketModelPolicy < ApplicationPolicy
  include PrivatePolicy

  def clone?
    true
  end
end
