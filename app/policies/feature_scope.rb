module FeatureScope
  def permitted_attributes
    user.admin? ? admin_attributes : attributes
  end

  def admin_attributes
    attributes << :featured
  end

  class Scope < PrivatePolicy::Scope
    def resolve
      scope = super.order(featured: :desc)

      if user
        scope.order("IF(`user_id` = #{ user.id }, 0, 1)").order(:name)
      else
        scope.order(:name)
      end
    end
  end
end
