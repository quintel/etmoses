class ChangeInstalledTechnologyStorageToVolume < ActiveRecord::Migration
  def up
    update_testing_grounds('storage', 'volume')
  end

  def down
    update_testing_grounds('volume', 'storage')
  end

  def update_testing_grounds(from_attr, to_attr)
    results = TestingGround.connection.execute(<<-SQL)
      SELECT id, technology_profile
      FROM testing_grounds
    SQL

    results.each do |(id, tech_json)|
      say "Updating TG: #{ id }"

      if tech_json.nil? || tech_json.start_with?('---')
        next
      else
        profile = JSON.parse(tech_json)
      end

      profile.each do |_, techs|
        techs.each do |tech|
          if tech.key?(from_attr)
            if tech[from_attr].nil?
              tech.delete(from_attr)
            else
              tech[to_attr] = tech.delete(from_attr)
            end

            if tech[to_attr].blank? &&
                tech['type'] == 'transport_car_using_electricity'
              # Set a default volume on electric cars which do not have one
              # specified.
              tech[to_attr] = 25.0
            end
          end
        end
      end

      TestingGround.where(id: id).update_all(
        technology_profile: JSON.dump(profile))
    end
  end
end
