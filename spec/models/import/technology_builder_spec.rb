require 'rails_helper'

RSpec.describe Import::TechnologyBuilder do
  let(:profiles) { ([nil] * 4).to_enum }
  let(:techs)    { Import::TechnologyBuilder.build('tech', data, profiles) }

  before do
    allow(Technology).to receive(:by_key).and_return(build(
      :technology, key: 'tech', import_from: 'electricity_output_capacity'
    ))
  end

  context 'importing a technology of three units' do
    let(:data) { {
      'number_of_units' => { 'future' => 3 },
      'electricity_output_capacity' => { 'future' => 0.02 }
    } }

    it 'imports three units' do
      expect(techs.length).to eq(3)
    end

    it 'assigns the technology name to each unit' do
      expect(techs[0]['name']).to eq('Tech #1')
      expect(techs[1]['name']).to eq('Tech #2')
      expect(techs[2]['name']).to eq('Tech #3')
    end

    it 'assigns the imported attribute' do
      value = Import::ElectricityOutputCapacityAttribute.call(data)

      expect(techs[0]['capacity']).to eq(value)
      expect(techs[1]['capacity']).to eq(value)
      expect(techs[2]['capacity']).to eq(value)
    end

    context 'when the response is missing the imported attribute' do
      let(:data) { {
        'number_of_units' => { 'future' => 3 }
      } }

      it 'imports three units' do
        expect(techs.length).to eq(3)
      end

      it 'sets the attribute to be zero' do
        expect(techs[0]['capacity']).to eq(0.0)
      end
    end

    context 'with no suitable profiles' do
      it 'assigns no profile attribute to each unit' do
        expect(techs[0]).to_not have_key('profile')
      end
    end # with no suitable profiles

    context 'with two suitable profiles' do
      let(:profiles) { (['one', 'two'] * 2).to_enum }

      it 'assigns profile attributes to each unit' do
        expect(techs[0]['profile']).to eq('one')
        expect(techs[1]['profile']).to eq('two')
        expect(techs[2]['profile']).to eq('one')
      end
    end
  end # importing a technology of three units

  context 'importing a technology of near-three units' do
    let(:data) { {
      'number_of_units' => { 'future' => 2.9 },
      'electricity_output_capacity' => { 'future' => 0.02 }
    } }

    it 'builds three units' do
      expect(techs.length).to eq(3)
    end
  end # importing a technology of near-three units

  context 'importing a technology of near-zero units' do
    let(:data) { {
      'number_of_units' => { 'future' => 0.1 },
      'electricity_output_capacity' => { 'future' => 0.02 }
    } }

    it 'builds no units' do
      expect(techs.length).to be_zero
    end
  end # importing a technology of near-zero units

  context 'importing a technology of zero units' do
    let(:data) { {
      'number_of_units' => { 'future' => 0.0 },
      'electricity_output_capacity' => { 'future' => 0.02 }
    } }

    it 'builds no units' do
      expect(techs.length).to be_zero
    end
  end # importing a technology of zero units
end # Import::TechnologyBuilder
