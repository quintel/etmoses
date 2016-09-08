class SetDefaultCopOnExistingLeses < ActiveRecord::Migration
  def up
    count   = TestingGround.count
    updated = 0

    TestingGround.find_each.with_index do |les, index|
      changed = false

      les.technology_profile.each_tech do |tech|
        # P2H has been removed.
        next if Technology.find_by_key(tech.type).nil?

        next if tech.whitelisted?(:performance_coefficient)

        cop = tech.performance_coefficient

        if ! cop.nil? && cop.to_f != 1.0
          changed = true
          tech.performance_coefficient = 1.0
        end
      end

      if changed
        updated += 1
        les.save(validate: false)
      end

      if ((index + 1) % 50).zero? || (index + 1) == count
        puts "Done #{ index + 1 } of #{ count }"
      end
    end

    puts "Finished. #{ updated } fixed."
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
