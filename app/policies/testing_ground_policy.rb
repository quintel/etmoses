class TestingGroundPolicy < ApplicationPolicy
  include PrivatePolicy

  def export?
    true
  end

  def calculate_concurrency?
    new? || edit?
  end

  alias_method :data?, :show?
  alias_method :process_data?, :show?
  alias_method :store_strategies?, :show?
  alias_method :technology_profile?, :show?
  alias_method :import?, :new?
  alias_method :perform_import?, :import?
  alias_method :perform_export?, :export?
  alias_method :save_as?, :edit?
end
