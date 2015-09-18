require 'rails_helper'

RSpec.describe Finance::BusinessCaseCalculator do
  let(:market_model_interactions){ MarketModels::Default.interactions }

  let(:market_model){
    FactoryGirl.create(:market_model, interactions: market_model_interactions)
  }

  let(:topology){
    FactoryGirl.create(:topology_with_stakeholders)
  }

  let(:testing_ground){
    FactoryGirl.create(:testing_ground, market_model: market_model, topology: topology)
  }

  let(:business_case){ Finance::BusinessCaseCalculator.new(testing_ground) }

  it "determines the correct headers" do
    expect(business_case.stakeholders).to eq(Stakeholder.all.sort)
  end

  it "determines the value of the business case" do
    price = business_case.send(:row, "customer", "customer")

    # 1 frame per hour (8760)
    # year-round loads of 0.9 and 3.3
    # 0.5 eur per unit
    expect(price).to eq(8760.0 * 0.5 * (0.9 + 3.3))
  end

  it "determines the rows of the business case" do
    expect(business_case).to receive(:stakeholders).twice.and_return(["customer"])

    expect(business_case.rows).to eq([{
      "customer" => [8760.0 * 0.5 * (0.9 + 3.3)]
    }])
  end
end
