module Network
  class PathCollection
    # Orders paths such that technologies which have no constraints come first,
    # followed by those with no excess constraint, with all others last.
    ConstraintOrder = lambda do |path|
      tech = path.technology

      # Technologies with no contraints; followed by technologies with only an
      # excess constraint; then those with only a capacity constraint; finally
      # those with both constraints.
      order = 1

      order <<= 1 if tech.excess_constrained?
      order <<= 2 if tech.capacity_constrained?

      order
    end # ConstraintOrder
  end # PathCollection
end
