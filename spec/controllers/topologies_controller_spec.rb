require 'rails_helper'

RSpec.describe TopologiesController do
  let(:user){ FactoryGirl.create(:user) }
  let(:testing_ground) { FactoryGirl.create(:testing_ground, user: user) }
  let!(:business_case) { FactoryGirl.create(:business_case, testing_ground: testing_ground, job_id: 1) }
  let(:topology) { FactoryGirl.create(:topology, testing_ground: testing_ground) }

  let!(:sign_in_user) { sign_in(user) }

  describe "#update" do
    before do
      patch :update, testing_ground_id: testing_ground.id, id: topology.id,
        topology: { graph: JSON.dump("name" => "HV") },
        format: :js
    end

    it "updates the topology" do
      expect(topology.reload.graph).to eq("name" => "HV")
    end

    it "clears the business case calculation" do
      expect(business_case.reload.job_id).to eq(nil)
    end
  end
end
