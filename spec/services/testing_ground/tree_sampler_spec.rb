require 'rails_helper'

RSpec.describe TestingGround::TreeSampler do
  let(:graph) { FakeLoadManagement.caching_graph(1, 35040) }

  let(:topology){ FactoryGirl.create(:topology, graph: graph) }

  let(:technology_profile) {
    TechnologyList.from_hash({})
  }

  let(:networks){
    [ network(:electricity), network(:gas) ]
  }

  def network(carrier)
    Network::Builders.for(carrier).build(topology.graph, technology_profile)
  end

  describe "with some info in the graph" do
    let(:graph) { FakeLoadManagement.caching_graph(1, [-15.0, 10.0, 0.0] * 11680) }

    it "picks the max deviation from zero" do
      sampled = TestingGround::TreeSampler.sample(networks)

      expect(sampled[:electricity][:children][0][:load][0]).to eq(-15.0)
    end
  end

  describe "with an empty graph" do
    let(:graph) { FakeLoadManagement.caching_graph(1, [0.0] * 35040) }

    it "samples parts of a tree" do
      sampled = TestingGround::TreeSampler.sample(networks, :low)

      expect(sampled[:electricity][:children][0][:load].length).to eq(365)
    end

    it "doesn't sample parts of a tree" do
      sampled = TestingGround::TreeSampler.sample(networks)

      expect(sampled[:electricity][:children][0][:load].length).to eq(35040)
    end
  end
end
