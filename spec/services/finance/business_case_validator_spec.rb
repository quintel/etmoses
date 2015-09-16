require 'rails_helper'

RSpec.describe Finance::BusinessCaseValidator do
  it "validates a business case" do
    topology = FactoryGirl.create(:topology_with_stakeholders)
    market_model = FactoryGirl.create(:market_model)

    expect(Finance::BusinessCaseValidator.new(topology, market_model).valid?).to eq(true)
  end

  it "validates a business case" do
    topology = FactoryGirl.create(:topology)
    market_model = FactoryGirl.create(:market_model)

    expect(Finance::BusinessCaseValidator.new(topology, market_model).valid?).to eq(false)
  end

  it "validates a business case" do
    topology = FactoryGirl.create(:topology_with_stakeholders)
    market_model = FactoryGirl.create(:market_model, interactions: [{
      "stakeholder_from"    => "customer",
      "stakeholder_to"      => "customer",
      "foundation"          => "connections",
      "applied_stakeholder" => "government",
      "tariff_type"         => "fixed",
      "tariff"              => 5.2
    }])

    expect(Finance::BusinessCaseValidator.new(topology, market_model).valid?).to eq(false)
  end
end
