class BusinessCasePolicy < ApplicationPolicy
  def update?
    record.testing_ground.user == user
  end

  alias :compare? :show?
  alias :compare_with? :show?
  alias :data? :show?
  alias :render_summary? :show?
  alias :validate? :create?
end
