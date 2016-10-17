class TopologyTemplatePolicy < ApplicationPolicy
  include PrivatePolicy
  include FeatureScope

  alias_method :download_as_png?, :show?
end
