require 'rails_helper'

module Network::Builders
  RSpec.describe Heat do
    let(:techs) do
      {
        child1: [{
          type: 'households_water_heater_district_heating_steam_hot_water',
          units: 10
        }]
      }
    end

    let(:list) { TechnologyList.from_hash(techs) }

    let(:tree) do
      { name: :parent, children: [{ name: :child1 }, { name: :child2 }] }
    end

    let(:sources_hash) do
      [{
        distance: 1,
        units: 1,
        key: 'households_collective_chp_biogas',
        heat_production: 0.0,
        priority: 0
      }, {
        distance: 1,
        key: 'central_heat_network_dispatchable',
        units: 0.0,
        heat_capacity: 3.71,
        heat_production: 0.0,
        priority: 1
      }]
    end

    let(:sources) { HeatSourceList.new(asset_list: sources_hash) }

    let(:park) { graph.head.get(:park) }

    # --------------------------------------------------------------------------

    context 'with no explicit volume-per-connection value' do
      let(:graph) do
        Heat.build(tree, list, sources, {})
      end

      it 'assigns a volume of 10kWh per connection' do
        # 10kWh * 4 (15 minute frames) * 10 (units)
        expect(park.buffer_tech.reserves.first.volume).to eql(400.0)
      end

      it 'assigns an amplified volume of 17.78kWh per connection' do
        expect(park.buffer_tech.reserves.first.high_volume).to eql(400.0 * 1.78)
      end
    end

    context 'an a volume-per-connection of 15kW' do
      let(:graph) do
        Heat.build(tree, list, sources, central_heat_buffer_capacity: 15.0)
      end

      it 'assigns a volume of 15kWh per connection' do
        # 15kWh * 4 (15 minute frames) * 10 (units)
        expect(park.buffer_tech.reserves.first.volume).to eql(600.0)
      end

      it 'assigns an amplified volume of 26.67kWh per connection' do
        expect(park.buffer_tech.reserves.first.high_volume).to eql(600.0 * 1.78)
      end
    end
  end # Heat
end
