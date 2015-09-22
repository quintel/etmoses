class DowncaseMeasureNamesInMarketModels < ActiveRecord::Migration
  def up
    MarketModel.find_each do |mm|
      downcased = mm.interactions.map do |interaction|
        next unless interaction.is_a?(Hash)

        interaction.delete('measure')

        if interaction['foundation']
          interaction['foundation'] = interaction['foundation'].downcase
        end

        # At the time of this migration, all MMs which use the kWh measure
        # probably intended to use kWh consumed. Change them:
        if interaction['foundation'] == 'kwh'
          interaction['foundation'] = 'kwh_consumed'
        end

        interaction
      end.compact

      mm.update_attributes!(interactions: downcased)
    end
  end

  def down
  end
end
