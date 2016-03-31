class GasAssetListPolicy < ApplicationPolicy
  include PrivatePolicy

  def update?
    record.testing_ground.user == user || user && user.admin?
  end

  def get_types?
    true
  end
end
