class RenameP2g < ActiveRecord::Migration
  CHANGE_FROM = 'energy_flexibility_p2g_electricity'
  CHANGE_TO = 'energy_hydrogen_flexibility_p2g_electricity'

  def up
    change_technologies!(CHANGE_FROM, CHANGE_TO)
  end

  def down
    change_technologies!(CHANGE_TO, CHANGE_FROM)
  end

  private

  def change_technologies!(from, to)
    ActiveRecord::Base.record_timestamps = false

    tgs = TestingGround.where('technology_profile LIKE ?', "%#{from}%")
    say "Updating #{tgs.count} testing grounds..."

    tgs.find_each do |tg|
      tg.technology_profile.to_h.values.each do |techs|
        techs.each { |tech| tech.type = to if tech.type == from }
      end

      tg.save(validate: false)
    end
  ensure
    ActiveRecord::Base.record_timestamps = true
  end
end
