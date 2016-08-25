class RemoveLegacyP2hTechnologies < ActiveRecord::Migration
  P2H_KEY = 'households_flexibility_p2h_electricity'.freeze

  def up
    TestingGround.find_each do |les|
      changed = false

      les.technology_profile.each do |_, techs|
        length = techs.length
        techs.reject! { |tech| tech.type == P2H_KEY }
        changed ^= (length != techs.length)
      end

      if changed
        les.save(validate: false)
        puts "Removed legacy stand-alone P2H from LES #{ les.id }"
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
