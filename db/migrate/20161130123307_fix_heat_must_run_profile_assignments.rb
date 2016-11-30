class FixHeatMustRunProfileAssignments < ActiveRecord::Migration
  def up
    profile = LoadProfile.where(key: 'constant').first!

    TestingGround.find_each do |les|
      update_needed = false
      source_list = les.heat_source_list

      # Old LESes may not have a heat source list.
      next unless source_list

      decorated = HeatSourceListDecorator.new(les.heat_source_list).decorate

      decorated.each do |tech|
        next if tech.dispatchable? || tech.profile

        tech.profile = profile.id
        update_needed = true
      end

      if update_needed
        source_list.update_attributes!(asset_list: decorated.map(&:attributes))
        puts "Updated heat source list for LES #{ les.id }"
      end
    end
  end
end
