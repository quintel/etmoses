class HeatAssetListPolicy < ApplicationPolicy
  include PrivatePolicy

  def update?
    record.testing_ground.user == user || user && user.admin?
  end
end
