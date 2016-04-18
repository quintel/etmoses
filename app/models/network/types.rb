module Network
  module Types
    include Dry::Types.module

    Efficiency = Coercible::Float.constrained(gteq: 0, lteq: 1).default(1.0)

    # dry-types does not like setting the default to Float::INFINITY.
    Capacity = Coercible::Float.constrained(gt: 0).default(1.0 / 0)
  end # Types
end
