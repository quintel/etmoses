class InstalledGasAsset
  include Virtus.model

  attribute :pressure_level_index, Integer
  attribute :part, String
  attribute :type, String
  attribute :amount, Integer, default: 1
  attribute :stakeholder, String
  attribute :building_year, Integer
  attribute :lifetime, Integer
  attribute :investment_cost, Float

  def decommissioning_year
    building_year + lifetime
  end

  def net_present_value_at(year)
    if year.between?(building_year, decommissioning_year)
      ((lifetime - (year.to_f - building_year.to_f)) / lifetime) * investment_cost
    else
      0
    end
  end

  def total_investment_costs
    investment_cost * amount
  end

  # Public: The pressure level (in bars) to which the asset is assigned.
  #
  # Returns a numeric.
  def pressure_level
    GasAssetList::PRESSURE_LEVELS[pressure_level_index]
  end

  # Public: The name of the pressure level to which the asset is assigned.
  #
  # Returns a Symbol.
  def pressure_level_name
    case pressure_level
      when 40 then :forty
      when  8 then :eight
      when  4 then :four
      else         :local
    end
  end

  # Public: The GasAsset record which contains the static data about this type
  # of asset.
  #
  # Returns a GasAssets::Base or subclass.
  def part_record
    klass = case part
      when 'pipes'.freeze      then GasAssets::Pipe
      when 'connectors'.freeze then GasAssets::Connector
      else fail "Unknown part type #{part}"
    end

    klass.find_by_type(type)
  end
end
