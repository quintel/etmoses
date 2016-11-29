class HeatAssetListPolicy < ApplicationPolicy
  include PrivatePolicy

  def update?
    record.testing_ground.user == user || user && user.admin?
  end

  alias :reload_heat_asset_list? :update?
end
