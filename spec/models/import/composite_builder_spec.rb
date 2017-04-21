require 'rails_helper'

RSpec.describe Import::CompositeBuilder do
  let(:gqueries) {
    {
      'etmoses_space_heating_buffer_demand' => {
        'present' => 100.0,
        'future'  => 10.0,
        'unit'    => 'PJ'
      },
      'etmoses_hot_water_buffer_demand' => {
        'present' => 200.0,
        'future'  => 20.0,
        'unit'    => 'PJ'
      },
      'number_of_residences' => {
        'present' => 0.0,
        'future'  => 1.0,
        'unit'    => 'number'
      }
    }
  }

  let(:composites) do
    Import::CompositeBuilder.new(gqueries, {
      id: 1,
      scaling: {
        'value' => '1.0', 'area_attribute' => 'number_of_residences'
      }
    }).build(nil)
  end

  context 'hot water buffers' do
    let(:buffer) do
      composites.detect { |c| c['type'] == 'buffer_water_heating' }
    end

    it 'are created' do
      expect(buffer).to be
    end

    it 'assigns hot water demand' do
      # PJ -> PWh -> kWh
      expect(buffer['demand']).
        to eq((20.0 * (1.0 / 3.6) * 1_000_000_000))
    end

    it 'assigns number of units' do
      expect(buffer['units']).to eq(1)
    end
  end


  context 'space heating buffers' do
    let(:buffer) do
      composites.detect { |c| c['type'] == 'buffer_space_heating' }
    end

    it 'are created' do
      expect(buffer).to be
    end

    it 'assigns space heating demand' do
      # PJ -> PWh -> kWh
      expect(buffer['demand']).
        to eq((10.0 * (1.0 / 3.6) * 1_000_000_000))
    end

    it 'assigns number of units' do
      expect(buffer['units']).to eq(1)
    end
  end
end
