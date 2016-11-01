class TopologyTemplatePolicy < ApplicationPolicy
  include PrivatePolicy
  include FeatureScope

  alias_method :download_as_png?, :show?
  alias_method :clone?, :update?
end
