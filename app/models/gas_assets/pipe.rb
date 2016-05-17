module GasAssets
  class Pipe < Base
    def part_type
      'pipe'
    end

    def default_amount
      attributes[:default_length_per_connection] || 0
    end
  end
end
