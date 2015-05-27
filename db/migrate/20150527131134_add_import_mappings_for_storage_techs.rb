class AddImportMappingsForStorageTechs < ActiveRecord::Migration
  EXPORT_MAP = {
    households_flexibility_p2p_electricity:
      :households_flexibility_p2p_electricity_market_penetration,
    households_flexibility_p2h_electricity:
      :households_flexibility_p2h_electricity_market_penetration,
    energy_flexibility_p2g_electricity:
      :number_of_energy_flexibility_p2g_electricity
  }

  def up
    technologies.each do |tech|
      tech.update_attributes!(export_to: EXPORT_MAP[tech.key.to_sym])

      importable_attrs = { technology: tech, name: 'input_capacity' }

      if ImportableAttribute.where(importable_attrs).empty?
        ImportableAttribute.create!(importable_attrs)
      end
    end
  end

  def down
    technologies.each do |tech|
      tech.update_attributes!(export_to: nil)

      ImportableAttribute.where(
        technology: tech, name: 'input_capacity'
      ).destroy
    end
  end

  def technologies
    Technology.where(key: EXPORT_MAP.keys)
  end
end
