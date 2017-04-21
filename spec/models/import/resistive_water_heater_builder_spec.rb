require 'rails_helper'

class Import
  RSpec.describe ResistiveWaterHeaterBuilder do
    let(:scaling)         { 0.0 }
    let(:p2h_share)       { 0.0 }
    let(:resistive_units) { 0.0 }
    let(:gas_units)       { 0.0 }
    let(:heat_pump_units) { 0.0 }

    let(:scenario) do
      {
        id: 1,
        scaling: {
          'value' => scaling,
          'area_attribute' => 'number_of_residences'
        }
      }
    end

    let(:gqueries) do
      {
        'share_of_p2h_in_hot_water_produced_in_households' => {
          'present' => 0.0,
          'future'  => p2h_share,
          'unit'    => 'factor'
        },
        'number_of_residences' => {
          'present' => 0.0,
          'future'  => 100.0,
          'unit'    => 'number'
        }
      }
    end

    let(:data) do
      [{
        'type' => 'households_water_heater_resistive_electricity',
        'units' => resistive_units
      }, {
        'type' => 'households_water_heater_heatpump_air_water_electricity',
        'units' => heat_pump_units
      }, {
        'type' => 'households_water_heater_network_gas',
        'units' => heat_pump_units
      }]
    end

    let(:builder) { ResistiveWaterHeaterBuilder.new(gqueries, scenario) }
    let(:result)  { builder.build(data).first }

    # --

    context 'with 100 households' do
      let(:scaling) { 100.0 }

      context 'and 50% use of power-to-heat' do
        let(:p2h_share) { 0.5 }

        context 'and sufficient electric heating technologies' do
          let(:resistive_units) { 50.0 }

          it 'does not increase the number of heaters' do
            expect(result['units']).to eq(50)
          end
        end

        context 'and no electric heating technologies' do
          let(:resistive_units) { 0.0 }

          it 'sets 50 electric heaters' do
            expect(result['units']).to eq(50)
          end
        end

        context 'and insufficient electric heating technologies' do
          let(:resistive_units) { 10.0 }

          it 'increases the number of heaters to 50' do
            expect(result['units']).to eq(50)
          end
        end

        context 'and 30 gas heaters' do
          let(:gas_units) { 30.0 }

          it 'sets 50 electric heaters' do
            expect(result['units']).to eq(50)
          end
        end

        context 'with 50 electric heat pumps' do
          let(:heat_pump_units) { 50.0 }

          it 'sets no electric heaters' do
            expect(result['units']).to be_zero
          end
        end

        context 'with 100 electric heat pumps' do
          let(:heat_pump_units) { 100.0 }

          it 'sets no electric heaters' do
            expect(result['units']).to be_zero
          end
        end

        context '30 gas heaters, 10 electric heat pumps' do
          let(:gas_units)       { 30.0 }
          let(:heat_pump_units) { 10.0 }

          it 'sets 40 electric heaters' do
            expect(result['units']).to eq(40)
          end
        end

        context 'and no resisitive heater included in the data' do
          let(:data) do
            super().reject do |tech|
              tech['type'] == 'households_water_heater_resistive_electricity'
            end
          end

          it 'does not include a heater' do
            expect(result).to be_nil
          end
        end # and no resisitive heater included in the data

        context 'and no electric heat pump included in the data' do
          let(:data) do
            super().reject do |tech|
              tech['type'] == 'households_water_heater_heatpump_air_water_electricity'
            end
          end

          it 'sets 50 electric heaters' do
            expect(result['units']).to eq(50)
          end
        end # and no electric heat pump included in the data
      end # ... and 50% use of power-to-heat
    end # with 100 households
  end # ResistiveWaterHeaterBuilder
end # Import
