class HeatSourceList < ActiveRecord::Base
  DEFAULT = {
    'key'                     => 'blank',
    'installed_heat_capacity' => '',
    'heat_production'         => '',
    'profile'                 => '1',
    'stakeholder'             => 'cooperation',
    'distance'                => '',
    'priority'                => ''
  }

  belongs_to :testing_ground

  serialize :source_list, JSON

  def sorted_source_list
    ([DEFAULT] + source_list).sort_by do |part|
      part['priority'].to_i || -1
    end
  end

  def source_list=(source_list)
    if source_list.is_a?(String)
      super(JSON.parse(source_list))
    else
      super(source_list)
    end
  end
end
