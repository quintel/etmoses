require 'rails_helper'

RSpec.describe Network::TechnologyPath do
  let(:tech) do
    network_technology(build(
      :installed_ev, profile: [0.0] * 8760, capacity: capacity, volume: capacity
    ), 8760, flexibility: false)
  end

  let(:source) { Network::Node.new(:source, capacity: 2.5) }
  let(:parent) { Network::Node.new(:parent, capacity: 2.0) }
  let(:child)  { Network::Node.new(:child) }

  before do
    source.connect_to(parent)
    parent.connect_to(child)

    child.set(:techs, [tech])
  end

  let(:path) { Network::TechnologyPath.new(tech, Network::Path.find(child)) }

  # --

  describe 'conditional_consumption_at' do
    before { allow(tech).to receive(:capacity_constrained?).and_return(true) }

    context 'when the technology is capacity constrained' do
      context 'and consumption is less than the constraint' do
        let(:capacity) { 1.0 }

        it 'does not modify consumption' do
          expect(path.conditional_consumption_at(0)).to eq(1.0)
        end
      end

      context 'and consumption is greater than the constraint' do
        let(:capacity) { 4.0 }

        it 'reduces exceedances' do
          expect(path.conditional_consumption_at(0)).to eq(2.0)
        end
      end
    end # when the technology is capacity constrained

    context 'when the technology is not capacity constrained' do
      before do
        allow(tech).to receive(:capacity_constrained?).and_return(false)
      end

      context 'and consumption is less than the constraint' do
        let(:capacity) { 1.0 }

        it 'does not modify consumption' do
          expect(path.conditional_consumption_at(0)).to eq(1.0)
        end
      end

      context 'and consumption is greater than the constraint' do
        let(:capacity) { 4.0 }

        it 'does not reduce exceedances' do
          expect(path.conditional_consumption_at(0)).to eq(4.0)
        end
      end
    end # when the technology is not capacity constrained
  end # conditional_consumption_at
end
