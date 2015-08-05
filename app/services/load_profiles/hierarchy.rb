module LoadProfiles
  class Hierarchy
    #
    # Query to sort Load Profile Categories hierarchly
    #

    def initialize
    end

    def tree_sort
      with_paths.sort do |category_a, category_b|
        category_a[:path] <=> category_b[:path]
      end
    end

    private

    def with_paths
      load_profile_categories.map do |load_profile_category|
        path = full_path(load_profile_category)

        { load_profile_category: load_profile_category,
                           path: path.join("."),
                      path_size: path.length - 1 }
      end
    end

    # Recursive method to generate a list of all load profile category parents
    def full_path(category, path = [])
      if category
        full_path(parent_category(category.parent_id),
                  path.unshift("#{category.name.downcase}#{category.id}"))
      else
        path
      end
    end

    def parent_category(parent_id)
      load_profile_categories.detect{|l| l.id == parent_id }
    end

    def load_profile_categories
      @load_profile_categories ||= LoadProfileCategory.all
    end
  end
end
