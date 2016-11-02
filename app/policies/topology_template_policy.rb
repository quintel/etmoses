class TopologyTemplatePolicy < ApplicationPolicy
  include PrivatePolicy
  include FeatureScope

  def attributes
    [:name, :public, :graph]
  end

  alias_method :download_as_png?, :show?
end
