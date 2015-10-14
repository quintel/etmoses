class LoadProfileCategory < ActiveRecord::Base
  include Hierarchy
  extend HierarchySort

  has_many :load_profiles
end
