require 'rails_helper'

RSpec.describe TopologiesController do
  let(:user){ FactoryGirl.create(:user) }

  describe "creating a topology" do
    let!(:sign_in_user){ sign_in(:user, user) }
    let(:perform_post){
      post :create, "topology"=>{
        "name"=>"Hello",
        "graph"=>"---\r\nname: HV Network\r\nchildren:\r\n- name: MV Network\r\n  children:\r\n  - name: \"LV #1\"\r\n  - name: \"LV #2\"\r\n  - name: \"LV #3\"\r\n"
      }
    }

    it 'creates a topology' do
      perform_post

      expect(Topology.count).to eq(1)
    end

    it "topology belongs to the user" do
      perform_post

      expect(Topology.last.user).to eq(user)
    end
  end

  describe "creating a topology with stakeholders" do
    let!(:sign_in_user){ sign_in(:user, user) }
    let(:perform_post){
      post :create, "topology"=>{
        "name"=>"Hello",
        "graph"=> YAML::dump(graph)
      }
    }

    describe 'wrongly' do
      let(:graph){
        {'name' => "HV Network", 'children' => [
          { 'name' => 'MV Network', 'children' => [
            {'name' => "LV #1", 'stakeholder' => 'not_a_stakeholder'}
          ]}
        ]}
      }

      it 'does not create a topology' do
        perform_post

        expect(Topology.count).to eq(0)
      end
    end

    describe 'correctly' do
      let(:graph){
        {'name' => "HV Network", 'children' => [
          { 'name' => 'MV Network', 'children' => [
            {'name' => "LV #1", 'stakeholder' => 'customer'}
          ]}
        ]}
      }

      it "does create a topology" do
        perform_post

        expect(Topology.count).to eq(1)
      end
    end
  end
end
