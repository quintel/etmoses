class LoadProfilePolicy < ApplicationPolicy
  include PrivatePolicy

  def modify_concurrency?
    user.admin?
  end
end
