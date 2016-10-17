class TopologyPolicy < ApplicationPolicy
  def update?
    super || record.testing_ground.user == user
  end

  def clone?
    true
  end

  alias_method :download_as_png?, :show?
end
