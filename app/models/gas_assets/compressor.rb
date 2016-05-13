module GasAssets
  class Compressor < Base
    def part_type
      'compressors'
    end

    def default_amount
      attributes[:default_units_per_connection] || 0
    end
  end
end

