require 'rails_helper'

RSpec.describe TestingGround::Cloner do
  let(:topology){ FactoryGirl.create(:topology) }
  let(:testing_ground){ FactoryGirl.create(:testing_ground, topology: topology) }

  let(:cloner){
    TestingGround::Cloner.new(testing_ground, topology, params)
  }

  describe "cloning when valid and only topology used" do
    let(:params){ { name: "Topology clone" } }

    it "keeps one topology" do
      cloner.clone

      expect(Topology.count).to eq(1)
    end

    it "ensure the topology is still attached to the testing ground" do
      cloner.clone

      expect(TestingGround.last.topology).to eq(topology)
    end
  end

  describe "clones a topology only if it's valid" do
    let(:params){ {
      name: "Topology clone",
      graph: "---\r\nname: HV Network\r\nchildren:\r\n- name: MV Network\r\n  children:\r\n  - name: \"LV #1\"\r\n  - name: \"LV #2\"\r\n  \r\n  \r\nFAILURE\r\n  - name: \"LV #3\"\r\n"
    } }

    it "doesn't change the current graph due to errors" do
      cloner.clone

      expect(Topology.last.graph).to eq({
        "name"=>"hv", "children"=>[{
          "name"=>"mv", "children"=>[
            {"name"=>"lv1"},
            {"name"=>"lv2"}]
          }]
      })
    end

    it "ensure the topology is still attached to the testing ground" do
      cloner.clone

      expect(TestingGround.last.topology).to eq(topology)
    end
  end

  describe "clones a topology only if it's valid" do
    let!(:another_testing_ground){ FactoryGirl.create(:testing_ground, topology: topology) }

    let(:params){ {
      name: "Topology clone",
      graph: "---\r\nname: HV Network\r\nchildren:\r\n- name: MV Network\r\n  children:\r\n  - name: \"LV #1\"\r\n  - name: \"LV #2\"\r\n  \r\n  \r\nFAILURE\r\n  - name: \"LV #3\"\r\n"
    } }

    it "doesn't change the current graph due to errors" do
      cloner.clone

      expect(Topology.last.graph).to eq({
        "name"=>"hv", "children"=>[{
          "name"=>"mv", "children"=>[
            {"name"=>"lv1"},
            {"name"=>"lv2"}]
          }]
      })
    end

    it "ensure the topology is still attached to the testing ground" do
      cloner.clone

      expect(TestingGround.last.topology).to eq(topology)
    end

    it "cloner errors" do
      cloner.clone

      expect(cloner.errors).to eq(["Graph (<unknown>): could not find expected ':' while scanning a simple key at line 10 column 1"])
    end
  end

  describe "cloning clears the testing grounds cache" do
    let(:params){ { name: "Topology clone" } }
    let!(:cache){ NetworkCache::Writer.from(testing_ground).write('lv1', [0.0] * 35040) }

    it "destroys the cache that's written" do
      cloner.clone

      expect(NetworkCache::Validator.from(testing_ground).valid?).to eq(false)
    end
  end
end
