module PrivatePolicy
  def update?
    record.user == user || user.admin?
  end

  alias_method :destroy?, :update?

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user && user.admin?
        scope.all
      else
        super.visible_to(user)
      end
    end
  end
end
