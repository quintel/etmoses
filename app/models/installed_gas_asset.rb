class InstalledGasAsset
  include Virtus.model
  include BusinessCaseCosts

  attribute :pressure_level_index, Integer
  attribute :part, String
  attribute :type, String
  attribute :units, Float, default: 1
  attribute :stakeholder, String, default: 'system operator'
  attribute :building_year, Integer
  attribute :technical_lifetime, Integer
  attribute :initial_investment, Float

  def decommissioning_year
    building_year + technical_lifetime
  end

  def net_present_value_at(year)
    if year.between?(building_year, decommissioning_year)
      ((technical_lifetime - (year.to_f - building_year.to_f)) / technical_lifetime) * initial_investment
    else
      0
    end
  end

  def total_investment_costs
    initial_investment * units
  end

  def om_costs_per_year
    part_record.yearly_o_and_m_cost
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

  # Public: The direction in which the asset works.
  #
  # Returns a Symbol.
  def direction
    part_record.direction
  end

  # Public: The GasAsset record which contains the static data about this type
  # of asset.
  #
  # Returns a GasAssets::Base or subclass.
  def part_record
    klass = case part
      when 'pipes'.freeze       then GasAssets::Pipe
      when 'connectors'.freeze  then GasAssets::Connector
      when 'compressors'.freeze then GasAssets::Compressor
      else fail "Unknown part type #{part}"
    end

    klass.find_by_type(type)
  end
end
