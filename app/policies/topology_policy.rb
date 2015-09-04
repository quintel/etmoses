class TopologyPolicy < ApplicationPolicy
  include PrivatePolicy

  def clone?
    true
  end
end
