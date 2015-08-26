class FixMarketModelSerialization < ActiveRecord::Migration
  def up
    conn = MarketModel.connection

    conn.select('SELECT id, interactions FROM market_models').each do |row|
      say "Updating MM #{ row['id'] }"

      interactions = JSON.parse(YAML.load(row['interactions']))

      interactions.each do |inter|
        tariff = inter['tariff']

        inter['tariff_type'], inter['tariff'] =
          case tariff
            when /[a-z]/i then ['curve', tariff]
            else               ['fixed', tariff.to_f]
          end
      end

      # Select only the ID. Otherwise it'll try to parse the YAML currently
      # stored as JSON.
      MarketModel.where(id: row['id']).select('id').first
        .update_attributes!(interactions: interactions)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
