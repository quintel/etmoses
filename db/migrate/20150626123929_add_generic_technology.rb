class AddGenericTechnology < ActiveRecord::Migration
  def up
    unless Technology.find_by_key('generic')
      Technology.create!(key: 'generic', name: 'Generic')
    end
  end

  def down
    Technology.by_key('generic').destroy
  end
end
