require 'rails_helper'

module Market::Measures
  RSpec.describe NumberOfConnections do
    let(:node)     { Network::Node.new(:thing) }
    let(:variant)  { Network::Node.new(:thing) }
    let(:variants) { { heat: ->*{ variant } } }

    # --------------------------------------------------------------------------

    def build_installed_double(type, units = 1)
      installed = instance_double('Network::Technologies::Composite::Manager')

      allow(installed).to receive(:installed).and_return(
        build(:installed_buffer_space_heating, type: type, units: units))

      installed
    end

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
        node.set(:comps, [
          build_installed_double('buffer_space_heating')
        ])
      end

      it 'has one heat connection' do
        expect(NumberOfHeatConnections.call(node, variants)).to eq(1)
      end
    end # with a node containing one buffer_space_heating technology

    context 'with a node containing a units=3 buffer_space_heating technology' do
      before do
        node.set(:comps, [
          build_installed_double('buffer_space_heating', 3)
        ])
      end

      it 'has one heat connection' do
        expect(NumberOfHeatConnections.call(node, variants)).to eq(3)
      end
    end # with a node containing a units=3 buffer_space_heating technology

    context 'with a node containing units=3 and units=2 buffer_space_heating technologies' do
      before do
        node.set(:comps, [
          build_installed_double('buffer_space_heating', 3),
          build_installed_double('buffer_space_heating', 2)
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
        node.set(:comps, [
          build_installed_double('buffer_water_heating')
        ])
      end

      it 'has one heat connection' do
        expect(NumberOfHeatConnections.call(node, variants)).to eq(1)
      end
    end # with a node containing one buffer_water_heating technology

    context 'with a node containing a units=3 buffer_water_heating technology' do
      before do
        node.set(:comps, [
          build_installed_double('buffer_water_heating', 3)
        ])
      end

      it 'has one heat connection' do
        expect(NumberOfHeatConnections.call(node, variants)).to eq(3)
      end
    end # with a node containing a units=3 buffer_water_heating technology

    context 'with a node containing units=3 and units=2 buffer_water_heating technologies' do
      before do
        node.set(:comps, [
          build_installed_double('buffer_water_heating', 3),
          build_installed_double('buffer_water_heating', 2)
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
        node.set(:comps, [
          build_installed_double('buffer_space_heating', 3),
          build_installed_double('buffer_water_heating', 2)
        ])
      end

      it 'has three heat connection' do
        expect(NumberOfHeatConnections.call(node, variants)).to eq(3)
      end
    end # with a node containing units=3 space heater and units=2 water heater
  end
end
