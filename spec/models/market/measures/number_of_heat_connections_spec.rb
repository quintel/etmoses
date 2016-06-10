require 'rails_helper'

module Market::Measures
  RSpec.describe NumberOfConnections do
    let(:node)     { Network::Node.new(:thing) }
    let(:variant)  { Network::Node.new(:thing) }
    let(:variants) { { heat: ->*{ variant } } }

    # --------------------------------------------------------------------------

    context 'with a node containing no heat variant' do
      let(:variant) { nil }

      it 'has zero heat connections' do
        expect(NumberOfHeatConnections.call(node, variants)).to be_zero
      end
    end # with a node containing no heat variant

    context 'with a node containing no buffer technologies' do
      it 'has zero heat connections' do
        expect(NumberOfHeatConnections.call(node, variants)).to be_zero
      end
    end # with a node containing no heat variant

    # Space heating
    # -------------

    context 'with a node containing one buffer_space_heating technology' do
      before do
        node.set(:techs, [
          network_technology(build(:installed_space_heater_heat_exchanger))
        ])
      end

      it 'has one heat connection' do
        expect(NumberOfHeatConnections.call(node, variants)).to eq(1)
      end
    end # with a node containing one buffer_space_heating technology

    context 'with a node containing a units=3 buffer_space_heating technology' do
      before do
        node.set(:techs, [network_technology(
          build(:installed_space_heater_heat_exchanger, units: 3)
        )])
      end

      it 'has one heat connection' do
        expect(NumberOfHeatConnections.call(node, variants)).to eq(3)
      end
    end # with a node containing a units=3 buffer_space_heating technology

    context 'with a node containing units=3 and units=2 buffer_space_heating technologies' do
      before do
        node.set(:techs, [
          network_technology(
            build(:installed_space_heater_heat_exchanger, units: 3)
          ),
          network_technology(
            build(:installed_space_heater_heat_exchanger, units: 2)
          )
        ])
      end

      it 'has five heat connection' do
        expect(NumberOfHeatConnections.call(node, variants)).to eq(5)
      end
    end # with a node containing units=3 and units=2 buffer_space_heating technologies

    # Hot water
    # ---------

    context 'with a node containing one buffer_water_heating technology' do
      before do
        node.set(:techs, [
          network_technology(build(:installed_water_heater_heat_exchanger))
        ])
      end

      it 'has one heat connection' do
        expect(NumberOfHeatConnections.call(node, variants)).to eq(1)
      end
    end # with a node containing one buffer_water_heating technology

    context 'with a node containing a units=3 buffer_water_heating technology' do
      before do
        node.set(:techs, [network_technology(
          build(:installed_water_heater_heat_exchanger, units: 3)
        )])
      end

      it 'has one heat connection' do
        expect(NumberOfHeatConnections.call(node, variants)).to eq(3)
      end
    end # with a node containing a units=3 buffer_water_heating technology

    context 'with a node containing units=3 and units=2 buffer_water_heating technologies' do
      before do
        node.set(:techs, [
          network_technology(
            build(:installed_water_heater_heat_exchanger, units: 3)
          ),
          network_technology(
            build(:installed_water_heater_heat_exchanger, units: 2)
          )
        ])
      end

      it 'has five heat connection' do
        expect(NumberOfHeatConnections.call(node, variants)).to eq(5)
      end
    end # with a node containing units=3 and units=2 buffer_water_heating technologies

    # Both
    # ----

    context 'with a node containing units=3 space heater and units=2 water heater' do
      before do
        node.set(:techs, [
          network_technology(
            build(:installed_space_heater_heat_exchanger, units: 3)
          ),
          network_technology(
            build(:installed_water_heater_heat_exchanger, units: 2)
          )
        ])
      end

      it 'has three heat connection' do
        expect(NumberOfHeatConnections.call(node, variants)).to eq(3)
      end
    end # with a node containing units=3 space heater and units=2 water heater
  end
end
