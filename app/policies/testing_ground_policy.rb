class TestingGroundPolicy < ApplicationPolicy
  include PrivatePolicy

  def export?
    true
  end

  def calculate_concurrency?
    new? || edit?
  end

  def show?
    super && ((show_topology? && show_market_model?) ||
               record.user == user || user.admin?)
  end

  def show_market_model?
    record.market_model ? record.market_model.public? : true
  end

  def show_topology?
    record.topology ? record.topology.public? : true
  end

  alias_method :data?, :show?
  alias_method :store_strategies?, :show?
  alias_method :technology_profile?, :show?
  alias_method :import?, :new?
  alias_method :perform_import?, :import?
  alias_method :perform_export?, :export?
  alias_method :save_as?, :edit?
  alias_method :fetch_etm_values?, :create?
end
