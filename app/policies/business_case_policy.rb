class BusinessCasePolicy < ApplicationPolicy
  def update?
    record.testing_ground.user == user
  end

  alias :compare? :show?
  alias :compare_with? :show?
end
