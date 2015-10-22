module Hierarchy
  attr_accessor :path

  def parent
    self.class.find_by_id(self.parent_id)
  end

  def children
    self.class.where(parent_id: self.id)
  end

  #
  # Uses sorted in 'HierarchySort' to detect the parent instead of querying the database
  def sort_parent(parent_id)
    self.class.sorted.detect do |sort_object|
      sort_object.id == parent_id
    end
  end

  def tree_path(object = self, path = [])
    if object
      tree_path(sort_parent(object.parent_id),
                path.unshift("#{object.name.downcase}#{object.id}"))
    else
      @path = path
    end
  end
end
