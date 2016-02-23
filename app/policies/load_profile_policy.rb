class LoadProfilePolicy < ApplicationPolicy
  include PrivatePolicy

  PERMITTED_ATTRIBUTES = [
    :key, :name, :public, :load_profile_category_id,
    :default_capacity, :default_demand, :default_volume,
    { technology_profiles_attributes: [:id, :technology, :_destroy] },
    { load_profile_components_attributes: [:id, :curve, :curve_type]}
  ].freeze

  def modify_concurrency?
    user.admin?
  end

  def permitted_attributes
    if modify_concurrency?
      PERMITTED_ATTRIBUTES.dup.push(:included_in_concurrency)
    else
      PERMITTED_ATTRIBUTES
    end
  end
end
