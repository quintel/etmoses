require 'rails_helper'

RSpec.describe Import::TechnologyBuilder do
  let(:techs) { Import::TechnologyBuilder.build('tech', data) }

  before do
    allow(Technology).to receive(:by_key).and_return(build_stubbed(
      :importable_technology, key: 'tech'
    ))
  end

  context 'importing a technology of three units' do
    let(:data) { {
      'number_of_units' => { 'future' => 3 },
      'electricity_output_capacity' => { 'future' => 0.02 }
    } }

    it 'builds one technology of three units' do
      expect(techs['units']).to eq(3)
    end

    it 'assigns the imported attribute' do
      value = Import::ElectricityOutputCapacityAttribute.call(data)

      expect(techs['capacity']).to eq(value)
    end

    context 'when the response is missing the imported attribute' do
      let(:data) { {
        'number_of_units' => { 'future' => 3 }
      } }

      it 'builds one technology of three units' do
        expect(techs['units']).to eq(3)
      end

      it 'sets the capacity to zero' do
        expect(techs['capacity']).to eq(0.0)
      end
    end
  end # importing a technology of three units

  context 'importing a technology of near-three units' do
    let(:data) { {
      'number_of_units' => { 'future' => 2.9 },
      'electricity_output_capacity' => { 'future' => 0.02 }
    } }

    it 'builds three units' do
      expect(techs['units']).to eq(3)
    end
  end # importing a technology of near-three units

  context 'importing a technology of near-zero units' do
    let(:data) { {
      'number_of_units' => { 'future' => 0.1 },
      'electricity_output_capacity' => { 'future' => 0.02 }
    } }

    it 'builds no units' do
      expect(techs['units']).to be_zero
    end
  end # importing a technology of near-zero units

  context 'importing a technology of zero units' do
    let(:data) { {
      'number_of_units' => { 'future' => 0.0 },
      'electricity_output_capacity' => { 'future' => 0.02 }
    } }

    it 'builds no units' do
      expect(techs['units']).to be_zero
    end
  end # importing a technology of zero units
end # Import::TechnologyBuilder
