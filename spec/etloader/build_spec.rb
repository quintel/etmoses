require 'spec_helper'
require 'yaml'

RSpec.describe 'Building a graph' do
  context 'with String keys' do
    let(:structure) { [{ 'name' => 'HV Network' }] }
    let(:graph)     { ETLoader.build(structure) }

    it 'creates the graph correctly' do
      expect(graph.node('HV Network')).to be
    end
  end # with String keys

  context 'with Symbol keys' do
    let(:structure) { [{ name: 'HV Network' }] }
    let(:graph)     { ETLoader.build(structure) }

    it 'creates the graph correctly' do
      expect(graph.node('HV Network')).to be
    end
  end # with Symbol keys

  context 'with a simple HV/MV/LVx3 layout' do
    let(:structure) do
      YAML.load(<<-EOS.gsub(/ {6}/, ''))
      ---
      - name: HV Network
        children:
        - name: MV Network
          children:
          - name: "LV #1"
          - name: "LV #2"
          - name: "LV #3"
      EOS
    end

    let(:graph) { ETLoader.build(structure) }

    it 'returns a Turbine::Graph' do
      expect(graph).to be_a(Turbine::Graph)
    end

    context 'HV Network' do
      let(:node) { graph.node('HV Network') }

      it 'exists' do
        expect(node).to be
      end

      it 'has no parents' do
        expect(node.in.to_a).to be_empty
      end
    end # HV Network

    context 'MV Network' do
      let(:node) { graph.node('MV Network') }

      it 'exists' do
        expect(node).to be
      end

      it 'belongs to "HV Network"' do
        expect(node.in.first).to eq(graph.node('HV Network'))
      end

      it 'has three children' do
        expect(node.out.to_a.length).to eq(3)
      end
    end # MV Network

    [ 'LV #1', 'LV #2', 'LV #3' ].each do |lv|
      context lv do
        let(:node) { graph.node(lv) }

        it 'exists' do
          expect(node).to be
        end

        it 'belongs to "MV Network' do
          expect(node.in.first).to eq(graph.node('MV Network'))
        end

        it 'has no children' do
          expect(node.out.to_a).to be_empty
        end
      end
    end # LV #1, LV #2, LV #3
  end # with a simple HV/MV/LVx3 layout
end # Building a graph
