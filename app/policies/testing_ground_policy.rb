class TestingGroundPolicy < ApplicationPolicy
  include PrivatePolicy

  def export?
    true
  end

  alias_method :clone?, :show?
  alias_method :data?, :show?
  alias_method :technology_profile?, :show?
  alias_method :import?, :new?
  alias_method :perform_import?, :import?
  alias_method :perform_export?, :export?
  alias_method :save_as?, :show?
  alias_method :update_strategies?, :edit?
  alias_method :fetch_etm_values?, :create?
  alias_method :render_template?, :create?
  alias_method :price_curve?, :show?
  alias_method :load_curves?, :show?
  alias_method :electricity_storage?, :show?
  alias_method :heat_load?, :show?
  alias_method :gas_load?, :show?
  alias_method :heat_load?, :show?
  alias_method :heat?, :show?
  alias_method :gas?, :show?
  alias_method :gas_level_summary?, :show?
end
