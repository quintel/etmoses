require 'rails_helper'

RSpec.describe TestingGround::Creator do
  it "creates a testing ground" do
    topology = FactoryGirl.create(:topology)
    TestingGround::Creator.new({
      scenario_id: 1,
      topology: topology,
      name: "Test testing ground"
    }).create

    expect(TestingGround.count).to eq(1)
  end
end
