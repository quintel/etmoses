require 'rails_helper'

RSpec.describe TopologyTemplatesController do
  let(:user) { FactoryGirl.create(:user) }
  let!(:sign_in_user) { sign_in(user) }

  describe "#new" do
    it 'visits new path' do
      get :new

      expect(response).to be_success
    end
  end

  describe "#create" do
    it 'creating a LES' do
      post :create, "topology_template"=>{
        "name"=>"Hello",
        "graph"=>"{\"name\":\"HV Network\",\"children\":[{\"name\":\"MV Network\",\"children\":[{\"name\":\"LV #1\"},{\"name\":\"LV #2\"},{\"name\":\"LV #3\"}]}]}"}

      expect(TopologyTemplate.count).to eq(2) # + the default
    end
  end

  describe "#edit" do
    let(:topology_template) {
      FactoryGirl.create(:topology_template, user: user)
    }

    it 'visits edit path' do
      get :edit, id: topology_template

      expect(response).to be_success
    end
  end

  describe "#show" do
    let(:topology_template) {
      FactoryGirl.create(:topology_template, user: user)
    }

    it 'visits show path' do
      get :show, id: topology_template

      expect(response).to be_success
    end
  end

  describe "#update" do
    let!(:sign_in_user) { sign_in(:user, user) }

    let(:topology_template) {
      FactoryGirl.create(:topology_template, user: user)
    }

    before do
      patch :update, id: topology_template.id,
        topology_template: { name: "Empty topology", featured: true }
    end

    describe "normal user" do
      let(:user) { FactoryGirl.create(:user) }

      it "should be able to update the topology template" do
        expect(topology_template.reload.name).to eq("Empty topology")
      end

      it "should not be possible to set it as featured" do
        expect(topology_template.reload.featured).to eq(false)
      end
    end

    describe "admin user" do
      let(:user) { FactoryGirl.create(:user, admin: true) }

      it "should be able to update the topology template" do
        expect(topology_template.reload.name).to eq("Empty topology")
      end

      it "should be possible to set it as featured" do
        expect(topology_template.reload.featured).to eq(true)
      end
    end
  end

  describe "#index" do
    it 'visits index path' do
      get :index

      expect(response).to be_success
    end
  end

  describe "#delete" do
    let(:topology_template){
      FactoryGirl.create(:topology_template, user: user)
    }

    let!(:topology) {
      FactoryGirl.create(:topology, topology_template: topology_template)
    }

    let!(:unaffected_topology) {
      FactoryGirl.create(:topology)
    }

    before do
      delete :destroy, id: topology_template.id
    end

    it "destroys the topology template" do
      expect(TopologyTemplate.count).to eq(2) # The default remains + the unaffected template
    end

    it "set's the associated topologies id's to nil" do
      expect(topology.reload.topology_template_id).to eq(nil)
    end

    it "doesn't affect other topologies" do
      expect(unaffected_topology.reload.topology_template_id).to_not be_blank
    end
  end
end
