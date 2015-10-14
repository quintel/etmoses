class Stakeholder < ActiveRecord::Base
  include Hierarchy
  extend HierarchySort
end
