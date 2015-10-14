module HierarchySort
  def tree_sort
    sorted.sort do |object_a, object_b|
      object_a.tree_path <=> object_b.tree_path
    end
  end

  def sorted
    @sorted ||= all
  end
end
