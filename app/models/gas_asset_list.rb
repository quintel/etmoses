class GasAssetList < ActiveRecord::Base
  DEFAULT = {
    "pressure_level" => "0.1",
    "part"           => "connectors",
    "type"           => "blank",
    "amount"         => "1",
    "stakeholder"    => "cooperation",
    "building_year"  => "1960"
  }

  belongs_to :testing_ground

  serialize :asset_list, JSON

  def sorted_asset_list
    ([DEFAULT] + asset_list).sort_by do |part|
      part['pressure_level'].to_f
    end
  end

  def asset_list=(asset_list)
    if asset_list.is_a?(String)
      super(JSON.parse(asset_list))
    else
      super(asset_list)
    end
  end
end
