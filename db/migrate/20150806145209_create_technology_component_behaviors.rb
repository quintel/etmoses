class CreateTechnologyComponentBehaviors < ActiveRecord::Migration
  def up
    create_table :technology_component_behaviors do |t|
      t.belongs_to :technology, null: false
      t.string :curve_type,     null: false, limit: 50
      t.string :behavior,       null: false, limit: 50

      t.index %w( technology_id curve_type ), unique: true,
        name: 'index_technology_curve_type'
    end

    TechnologyComponentBehavior.reset_column_information

    base_load           = Technology.by_key('base_load')
    base_load_buildings = Technology.by_key('base_load_buildings')

    TechnologyComponentBehavior.create!(
      technology:  base_load,
      curve_type: 'flex',
      behavior:   'deferrable'
    )

    TechnologyComponentBehavior.create!(
      technology:  base_load,
      curve_type: 'inflex',
      behavior:   'generic'
    )

    TechnologyComponentBehavior.create!(
      technology:  base_load_buildings,
      curve_type: 'flex',
      behavior:   'optional'
    )

    TechnologyComponentBehavior.create!(
      technology:  base_load_buildings,
      curve_type: 'inflex',
      behavior:   'generic'
    )
  end

  def down
    drop_table :technology_component_behaviors
  end
end
