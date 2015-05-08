require 'rails_helper'

RSpec.describe TopologiesController do
  let(:user){ FactoryGirl.create(:user) }
  it 'creates a topology' do
    sign_in(:user, user)

    post :create, "topology"=>{
      "name"=>"Hello",
      "graph"=>"---\r\nname: HV Network\r\nchildren:\r\n- name: MV Network\r\n  children:\r\n  - name: \"LV #1\"\r\n  - name: \"LV #2\"\r\n  - name: \"LV #3\"\r\n"
    }

    expect(Topology.count).to eq(1)
  end
end
