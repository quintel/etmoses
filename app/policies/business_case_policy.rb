class BusinessCasePolicy < ApplicationPolicy
  def update?
    record.testing_ground.user == user
  end
end
