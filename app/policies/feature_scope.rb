module FeatureScope
  def permitted_attributes
    attributes = [:name, :public, :interactions]

    if user.admin?
      attributes << :featured
    end

    attributes
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
