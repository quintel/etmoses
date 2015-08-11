class ChangeExistingCurveComponentTypes < ActiveRecord::Migration
  def up
    LoadProfile.find_each do |profile|
      profile.load_profile_components.each do |component|
        type =
          case component.curve_file_name
            when /_inflex/ then 'inflex'
            when /_flex/   then 'flex'
            else                'default'
          end

        component.update_attributes!(curve_type: type)
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
