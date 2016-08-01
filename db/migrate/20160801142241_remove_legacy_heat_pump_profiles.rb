class RemoveLegacyHeatPumpProfiles < ActiveRecord::Migration
  def up
    main = LoadProfileCategory.where(name: 'Legacy "stand-alone" heat pumps').first!
    subs = all_subcategories(main)

    LoadProfile.where(load_profile_category_id: [main.id, *subs.map(&:id)]).destroy_all

    subs.map(&:destroy)
    main.destroy
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end

  private

  def all_subcategories(parent)
    (Array(parent.children) +
      parent.children.map { |child| all_subcategories(child) }).flatten
  end
end
