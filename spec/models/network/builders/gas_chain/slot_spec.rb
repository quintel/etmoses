require 'rails_helper'

module Network::Builders
  RSpec.describe GasChain::Slots do
    let(:result) { GasChain::Slots.new(:four, assets).build }

    context 'with no assets' do
      let(:assets) { [] }

      it 'has a default upward slot' do
        expect(result[:upward]).to eq(Network::Chain::Slot.upward)
      end

      it 'has a default downward slot' do
        expect(result[:downward]).to eq(Network::Chain::Slot.downward)
      end
    end # with no assets

    context 'with only "pipes" assets in the pressure level' do
      let(:assets) do
        [InstalledGasAsset.new(
          pressure_level_index: 1,
          part: 'pipes',
          type: 'big_pipe'
        )]
      end

      it 'has a default upward slot' do
        expect(result[:upward]).to eq(Network::Chain::Slot.upward)
      end

      it 'has a default downward slot' do
        expect(result[:downward]).to eq(Network::Chain::Slot.downward)
      end
    end # with only "pipes" assets in the pressure level

    context 'with only "connectors" assets in other pressure levels' do
      let(:assets) do
        [InstalledGasAsset.new(
          pressure_level_index: 3,
          part: 'connectors',
          type: 'inefficient_connector'
        )]
      end

      it 'has a default upward slot' do
        expect(result[:upward]).to eq(Network::Chain::Slot.upward)
      end

      it 'has a default downward slot' do
        expect(result[:downward]).to eq(Network::Chain::Slot.downward)
      end
    end # with only "connectors" assets in other pressure levels

    context 'with a single "connectors" asset in the pressure level' do
      let(:assets) do
        [InstalledGasAsset.new(
          pressure_level_index: 1,
          part: 'connectors',
          type: 'inefficient_connector'
        )]
      end

      context 'the upward slot' do
        it 'it takes capacity from the asset' do
          expect(result[:upward].capacity).to eql(3.0)
        end

        it 'it takes efficiency from the asset' do
          expect(result[:upward].efficiency).to eql(0.8)
        end
      end

      context 'the downward slot' do
        it 'it takes capacity from the asset' do
          expect(result[:downward].capacity).to eql(2.0)
        end

        it 'it takes efficiency from the asset' do
          expect(result[:downward].efficiency).to eql(0.5)
        end
      end
    end # with a single "connectors" asset in the pressure level

    context 'with a 2 units of a single "connectors" asset' do
      let(:assets) do
        [InstalledGasAsset.new(
          pressure_level_index: 1,
          part: 'connectors',
          amount: 2,
          type: 'inefficient_connector'
        )]
      end

      context 'the upward slot' do
        it 'it multiplies capacity by the number of units' do
          expect(result[:upward].capacity).to eql(6.0)
        end

        it 'it takes efficiency from the asset' do
          expect(result[:upward].efficiency).to eql(0.8)
        end
      end

      context 'the downward slot' do
        it 'it multiplies capacity by the number of units' do
          expect(result[:downward].capacity).to eql(4.0)
        end

        it 'it takes efficiency from the asset' do
          expect(result[:downward].efficiency).to eql(0.5)
        end
      end
    end # with a 2 units of a single "connectors" asset

    context 'with a two "connectors" assets in the pressure level' do
      let(:assets) do
        [
          InstalledGasAsset.new(
            pressure_level_index: 1,
            part: 'connectors',
            type: 'inefficient_connector'
          ),
          InstalledGasAsset.new(
            pressure_level_index: 1,
            part: 'connectors',
            type: 'big_connector'
          )
        ]
      end

      context 'the upward slot' do
        it 'it combines the capacity of the assets' do
          expect(result[:upward].capacity).to eql(4.0)
        end

        it 'adjusts efficiency accounting for capacity' do
          # eff * cap
          # ---   ---
          # 0.8 * 3.0 (inefficient connector)
          # 1.0 * 1.0 (big connector)
          #       / 4 (total capacity)
          #    = 0.85
          expect(result[:upward].efficiency).to eql((0.8 * 3 + 1.0) / 4.0)
        end
      end

      context 'the downward slot' do
        it 'it combines the capacity of the assets' do
          expect(result[:downward].capacity).to eql(3.0)
        end

        it 'adjusts efficiency accounting for capacity' do
          # eff * cap
          # ---   ---
          # 0.5 * 2.0 (inefficient connector)
          # 1.0 * 1.0 (big connector)
          #       / 3 (total capacity)
          #    = 0.66
          expect(result[:downward].efficiency).to eql((0.5 * 2 + 1.0) / 3.0)
        end
      end
    end # with a two "connectors" assets in the pressure level

    context 'with assets of zero units' do
      let(:assets) do
        [InstalledGasAsset.new(
          pressure_level_index: 1,
          part: 'connectors',
          type: 'inefficient_connector',
          amount: 0
        )]
      end

      it 'has a default upward slot' do
        expect(result[:upward]).to eq(Network::Chain::Slot.upward)
      end

      it 'has a default downward slot' do
        expect(result[:downward]).to eq(Network::Chain::Slot.downward)
      end
    end # with assets of zero units
  end # GasChain::Slots
end # Network::Builders
