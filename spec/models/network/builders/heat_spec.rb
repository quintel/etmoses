require 'rails_helper'

module Network::Builders
  RSpec.describe Heat do
    let(:graph) { Heat.build(tree, list, sources) }
    let(:techs) { {} }
    let(:list)  { TechnologyList.from_hash(techs) }

    let(:tree) {{
      name: :parent,
      children: [{ name: :child1 }, { name: :child2 }]
    }}

    let(:sources_hash) {
      [{
        "total_initial_investment" => 800.0,
        "om_costs_per_year" => 25.0,
        "technical_lifetime" => 30.0,
        "marginal_costs" => 0.0,
        "distance" => 1,
        "units" => 1,
        "key" => "households_collective_chp_biogas",
        "heat_production" => 0.0,
        "priority" => 0
      },
      {
        "distance" => 1,
        "key" => "central_heat_network_dispatchable",
        "name" => "Geothermal",
        "units" => 0.0,
        "heat_capacity" => 3.71,
        "heat_production" => 0.0,
        "total_initial_investment" => 1000.0,
        "technical_lifetime" => 25.0,
        "om_costs_per_year" => 7.55,
        "marginal_costs" => 0.0,
        "priority" => 1
      }]
    }

    let(:sources) { HeatSourceList.new(source_list: sources_hash) }

    # --------------------------------------------------------------------------

    context 'trying something' do
      it 'works' do
        true
      end
    end
  end # Heat
end
