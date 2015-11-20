class TopologyPolicy < ApplicationPolicy
  include PrivatePolicy

  def clone?
    true
  end

  alias_method :download_as_png?, :show?
end
