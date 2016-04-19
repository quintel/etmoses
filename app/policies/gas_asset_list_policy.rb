class GasAssetListPolicy < ApplicationPolicy
  include PrivatePolicy

  def update?
    record.testing_ground.user == user || user && user.admin?
  end

  def get_types?
    true
  end

  alias :calculate_cumulative_investment? :update?
  alias :calculate_net_present_value? :update?
  alias :reload_gas_asset_list? :update?
  alias :load_summary? :update?
  alias :fake_gas_load? :update?
end
