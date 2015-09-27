require 'rails_helper'

RSpec.describe Finance::BusinessCaseComparator do
  let(:financials){
    [ {"aggregator"     =>[0, 0]},
      {"cooperation"    =>[1, 0]} ]
  }

  let(:other_financials){
    [ {"aggregator"     =>[1, 3]},
      {"cooperation"    =>[1, 0]} ]
  }

  let(:business_case){
    FactoryGirl.create(:business_case, financials: financials)
  }

  let(:other_business_case){
    FactoryGirl.create(:business_case, financials: other_financials)
  }

  it "compares two business cases" do
    compare = Finance::BusinessCaseComparator.new(business_case, other_business_case).compare

    expect(compare).to eq([[3, 2, 0, 1], [1, 3, 0, -2]]);
  end

  context 'when a business case is missing a stakeholder' do
    let(:other_financials){
      [ {"aggregator" =>[1, 3]} ]
    }

    it "compares two business cases" do
      compare = Finance::BusinessCaseComparator.new(
        business_case, other_business_case
      ).compare

      expect(compare).to eq([[3, 1, 0, 2], [0, 0, 0, 0]]);
    end
  end
end
