require 'rails_helper'

RSpec.describe HeatSourceList::SourceListFetcher do
  let(:testing_ground) { FactoryGirl.create(:testing_ground) }

  let(:heat_sources_result) do
    { 'nodes' => {
      'households_collective_chp_biogas' => {
        'heat_output_capacity' => {
          'present' => 1.0, 'future' => 2.0
        },
        'technical_lifetime' => {
          'present' => 1.0, 'future' => 2.0
        },
        'total_initial_investment_per_mw' => {
          'present' => 0.0, 'future' => 2000.0
        },
        'marginal_heat_costs' => {
          'present' => 1.0, 'future' => 2.0
        },
        'variable_costs_per_unit' => {
          'present' => 1.0, 'future' => 2.0
        },
        'number_of_units' => {
          'present' => 1.0, 'future' => 2.0
        }
      }
    } }
  end

  let!(:stub_et_engine_request) {
    stub_request(
      :post,
      'https://beta-engine.energytransitionmodel.com/api/v3/scenarios/1/converters/stats'
    ).with(
        headers: { 'Accept' => 'application/json' },
        body: {
          'keys' => {
            'households_collective_chp_biogas' => ['heat_output_capacity']
          }
        }
      ).to_return(
        status: 200,
        body: JSON.dump(heat_sources_result),
        headers: {}
      )
  }

  let!(:stub_gqueries) do
    expect_any_instance_of(Import::GqueryRequester).to receive(:request)
      .with(id: 1)
      .and_return({
        'central_heat_network_dispatchable' => {},
        'central_heat_network_must_run' => {}
      })
  end

  let(:source_list) do
    HeatSourceList::SourceListFetcher.new(testing_ground).fetch
  end

  it 'expects two technologies' do
    expect(source_list.size).to eq(3)
  end

  context 'central heat network' do
    let(:source) do
      source_list.detect do |source|
        source['key'] == 'central_heat_network_dispatchable'
      end
    end

    it 'sets the correct defaults' do
      expect(source.fetch('total_initial_investment')).to eq(100000.0)
    end
  end

  context 'ETEngine related heat source' do
    let(:source) do
      source_list.detect do |source|
        source['key'] == 'households_collective_chp_biogas'
      end
    end

    it 'sets the correct units' do
      expect(source.fetch('units')).to eq(2)
    end

    it 'sets the correct installed heat capacity' do
      expect(source.fetch('heat_capacity')).to eq(2000.0)
    end

    it 'sets the heat production' do
      # amount of units * the installed capacity in MWh * 1000
      expect(source.fetch('heat_production')).to eq(4000.0)
    end

    it 'sets the marginal costs' do
      expect(source.fetch('marginal_heat_costs')).to eq(0.002)
    end

    it 'sets the technical lifetime' do
      expect(source.fetch('technical_lifetime')).to eq(2.0)
    end

    it 'sets the total investment costs' do
      expect(source.fetch('total_initial_investment')).to eq(2.0)
    end

    context 'when the source has zero units' do
      let(:heat_sources_result) do
        result = super()
        biogas = result['nodes']['households_collective_chp_biogas']

        biogas['number_of_units'] = { 'present' => 1.0, 'future' => 0.0 }

        result
      end

      it 'omits the technology' do
        tech_keys = source_list.map { |source| source['key'] }
        expect(tech_keys).not_to include('households_collective_chp_biogas')
      end
    end
  end

  context 'central heat networks' do
    let(:tech_keys) { source_list.map {|source| source['key'] } }

    it 'expects both to be central heat networks' do
      expect(tech_keys).to include('central_heat_network_must_run')
    end

    it 'expects both to be central heat networks' do
      expect(tech_keys).to include('central_heat_network_dispatchable')
    end
  end
end
