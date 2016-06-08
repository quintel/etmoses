module Network
  module Types
    include Dry::Types.module

    Efficiency    = Coercible::Float.constrained(gteq: 0, lteq: 1).default(1.0)
    Volume        = Coercible::Float.constrained(gteq: 0)
    NumberOfUnits = Coercible::Float.default(1.0)

    # dry-types does not like setting the default to Float::INFINITY.
    #
    # TODO Capacity ought to be "gt: 0", not "gteq: 0". The latter is currently
    # used in case the enters a zero capacity. Front-end validation should catch
    # this.
    Capacity        = Coercible::Float.constrained(gteq: 0).default(1.0 / 0)
    NonZeroCapacity = Coercible::Float.constrained(gt: 0).default(1.0 / 0)
  end # Types
end
