class AddStorageTechnologies < ActiveRecord::Migration
  TECHS = [{
    key:      'households_flexibility_p2p_electricity',
    name:     'Battery',
    behavior: 'storage'
  }, {
    key:      'energy_flexibility_p2g_electricity',
    name:     'Power-To-Gas',
    behavior: 'siphon'
  }, {
    key:      'households_flexibility_p2h_electricity',
    name:     'Power-To-Heat',
    behavior: 'buffer'
  }]

  def up
    TECHS.each(&Technology.method(:create!))
  end

  def down
    TECHS.each do |data|
      Technology.by_key!(data[:key]).destroy
    end
  end
end
