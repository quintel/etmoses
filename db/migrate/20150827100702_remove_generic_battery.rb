class RemoveGenericBattery < ActiveRecord::Migration
  FROM = 'battery'
  TO   = 'households_flexibility_p2p_electricity'

  def up
    (battery = Technology.find_by_key('battery')) && battery.destroy

    say 'Updating testing grounds...'

    TestingGround.find_each do |tg|
      any_changed = false

      tg.technology_profile.each_tech do |tech|
        if tech.type == FROM
          any_changed = true
          tech.type = TO
        end
      end

      if any_changed
        say "Updated battery in testing ground ##{ tg.id }"
        tg.save(validate: false)
      end
    end
  end

  def down
    Technology.create!(
      key: FROM,
      name: 'Generic Battery',
      behavior: 'storage')
  end
end
