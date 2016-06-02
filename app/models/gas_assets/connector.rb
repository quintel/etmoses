module GasAssets
  class Connector < Base
    def part_type
      'connector'
    end

    def direction
      :downward
    end

    def default_amount
      attributes[:default_units_per_connection] || 0
    end
  end
end
