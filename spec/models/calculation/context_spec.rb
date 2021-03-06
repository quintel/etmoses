require 'rails_helper'

RSpec.describe Calculation::Context do
  let(:testing_ground) { FactoryGirl.create(:testing_ground) }
  let(:context) { Calculation::Context.new([graph]) }
  let(:graph)   { Network::Graph.new(:electricity) }

  context 'with a graph containing no profiles' do
    it 'contains the graph' do
      expect(context.graph(:electricity)).to eq(graph)
    end

    it 'has a length of 1' do
      expect(context.length).to eq(1)
    end

    it 'permits iteration of each frame' do
      results = []
      context.frames { |frame| results.push(frame) }

      expect(results).to eq([0])
    end

    it 'permits chained iteration of each frame' do
      expect(context.frames.map.to_a).to eq([0])
    end
  end # with a graph containing no profiles

  context 'with a graph containing a load profile' do
    let(:profile) { create(:load_profile_with_curve) }
    let(:tg)      { create(:testing_ground) }
    let(:graph)   { tg.network(:electricity) }

    before do
      tg.technology_profile = { 'lv1' => [{
        'name' => 'Tech One', 'profile' => profile.id
      }]}
    end

    it 'has a length equal to the full length of the curves' do
      expect(context.length).
        to eq(profile.load_profile_components.first.network_curve.length)
    end

    it 'permits iteration of each frame' do
      results = []
      context.frames { |frame| results.push(frame) }

      expect(results.length).
        to eq(profile.load_profile_components.first.network_curve.length)

      expect(results.take(5)).to eq([0, 1, 2, 3, 4])
    end

    it 'permits chained iteration of each frame' do
      results = context.frames.map.to_a

      expect(results.length).
        to eq(profile.load_profile_components.first.network_curve.length)

      expect(results.take(5)).to eq([0, 1, 2, 3, 4])
    end

    context 'with a profile range of 0...168' do
      let(:context) { Calculation::Context.new([graph], range: 0...168) }

      it 'truncates profiles to 168 elements' do
        expect(context.length).to eq(168)
      end

      it 'permits iteration of each frame' do
        results = []
        context.frames { |frame| results.push(frame) }

        expect(results.length).to eq(168)
        expect(results.take(5)).to eq([0, 1, 2, 3, 4])
      end
    end # with a profile range of 0...168
  end
end # describe Calculation::Context
