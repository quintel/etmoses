require 'rails_helper'

RSpec.describe Calculation::Context do
  let(:context) { Calculation::Context.new(graph) }
  let(:graph)   { Turbine::Graph.new }

  context 'with a graph containing no profiles' do
    it 'contains the graph' do
      expect(context.graph).to eq(graph)
    end

    it 'has a length of 1' do
      expect(context.length).to eq(1)
    end

    it 'permits iteration of each point' do
      results = []
      context.points { |point| results.push(point) }

      expect(results).to eq([0])
    end

    it 'permits chained iteration of each point' do
      expect(context.points.map.to_a).to eq([0])
    end
  end # with a graph containing no profiles

  context 'with a graph containing a load profile' do
    let(:profile) { create(:load_profile) }
    let(:tg)      { create(:testing_ground) }
    let(:graph)   { tg.to_graph }

    before do
      tg.technologies = { 'lv1' => [{
        'name' => 'Tech One', 'profile' => profile.key
      }]}
    end

    it 'has a length equal to the load curve' do
      expect(context.length).to eq(profile.merit_curve.length)
    end

    it 'permits iteration of each point' do
      results = []
      context.points { |point| results.push(point) }

      expect(results.length).to eq(8760)
      expect(results.take(5)).to eq([0, 1, 2, 3, 4])
    end

    it 'permits chained iteration of each point' do
      results = context.points.map.to_a

      expect(results.length).to eq(8760)
      expect(results.take(5)).to eq([0, 1, 2, 3, 4])
    end
  end
end # describe Calculation::Context
