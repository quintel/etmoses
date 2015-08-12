require 'rails_helper'

module Market::Measures
  RSpec.describe NumberOfConnections do
    let(:node) { Network::Node.new(:thing) }

    context 'with one base_load technology' do
      before do
        node.set(:techs, [network_technology(build(:installed_base_load))])
      end

      context 'and one unit' do
        it 'has one connection' do
          expect(NumberOfConnections.call(node)).to eq(1)
        end
      end

      context 'and three units' do
        before { node.get(:techs).first.installed.units = 3 }

        it 'has three connections' do
          expect(NumberOfConnections.call(node)).to eq(3)
        end
      end
    end # with one base_load technology

    context 'with three base_load technologies' do
      before do
        node.set(:techs, [
          network_technology(build(:installed_base_load)),
          network_technology(build(:installed_base_load)),
          network_technology(build(:installed_base_load))
        ])
      end

      context 'each with one unit' do
        it 'has three connections' do
          expect(NumberOfConnections.call(node)).to eq(3)
        end
      end

      context 'each with two units' do
        before { node.get(:techs).each { |t| t.installed.units = 2 } }

        it 'has six connections' do
          expect(NumberOfConnections.call(node)).to eq(6)
        end
      end
    end

    context 'with one base_load_buildings technology' do
      before do
        node.set(:techs, [
          network_technology(build(:installed_base_load_building))
        ])
      end

      it 'has one connection' do
        expect(NumberOfConnections.call(node)).to eq(1)
      end
    end # with one base_load_buildings technology
  end # NumberOfConnections
end # Market::Measures
