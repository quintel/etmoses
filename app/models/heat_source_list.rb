class HeatSourceList < AssetList
  DEFAULT = {
    key:                     'blank',
    installed_heat_capacity: '',
    heat_production:         '',
    profile:                 '1',
    stakeholder:             'cooperation',
    distance:                '',
    priority:                ''
  }

  def sorted_asset_list
    ([DEFAULT] + asset_list).sort_by do |part|
      part['priority'].to_i || -1
    end
  end
end
