module PrivatePolicy
  def update?
    record.user == user
  end

  alias_method :destroy?, :update?

  class Scope < ApplicationPolicy::Scope
    def resolve
      super.visible_to(user)
    end
  end
end
