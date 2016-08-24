class UpdateBuffersForExistingLesses < ActiveRecord::Migration
  def fetch_buffer_for_technology(testing_ground, technology)
    testing_ground.technology_profile.each_tech.detect do |tech|
      (technology.buffer == tech.composite_value) ||
        tech.includes.include?(technology.type) # This is due to some LES's with broken buffers
    end
  end

  def update_technologies(testing_ground, technologies, indices)
    technologies.flat_map do |technology|
      if technology.position_relative_to_buffer
        buffer = fetch_buffer_for_technology(testing_ground, technology)

        index = indices[buffer.type] += 1

        cloned_buffer                 = buffer.dup
        cloned_buffer.composite_index = index
        cloned_buffer.composite_value = "#{ cloned_buffer.type }_#{ index }"
        cloned_buffer.units           = technology.units
        technology.buffer             = cloned_buffer.composite_value

        [ cloned_buffer, technology ]
      elsif !technology.composite
        technology
      end
    end
  end

  def up
    TestingGround.all.each do |testing_ground|
      indices = Hash.new { |h, k| h[k] = 0 }

      list = Hash[testing_ground.technology_profile.list.map do |node, technologies|
        [node, update_technologies(testing_ground, technologies, indices).compact]
      end]

      testing_ground.update_column(
        :technology_profile, TechnologyList.dump(TechnologyList.new(list)))

      puts "Updating LES ##{ testing_ground.id }"
    end
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
