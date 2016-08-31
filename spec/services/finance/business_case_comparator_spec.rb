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

  let(:compare) {
    Finance::BusinessCaseComparator.new(
      business_case, other_business_case
    ).compare
  }

  it "compares two business cases" do
    expect(compare.map{|t| t[:compare][:total] }).to eq([1, -2])
  end

  context 'when a business case is missing a stakeholder' do
    let(:other_financials){
      [ {"aggregator" =>[1, 3]} ]
    }

    it "compares two business cases" do
      expect(compare.map{|t| t[:compare] }).to eq([
        { :stakeholder=>"aggregator",
          :incoming=>3,
          :incoming_breakdown=>{"Yearly depreciation + fixed O&M costs"=>3},
          :outgoing=>1,
          :outgoing_breakdown=>{"Yearly depreciation + fixed O&M costs"=>1},
          :freeform=>nil,
          :total=>2 },
        nil
      ]);
    end
  end

  context 'when a business case is missing a stakeholder' do
    let(:other_financials){
      [ {"no_stakeholder" =>[1, 3]}, {"aggregator" =>[1, 3]}]
    }

    it "compares two business cases" do
      # There are three unique stakeholders, Aggreagator, no_stakeholder
      # and Cooperation. One of the compare values should be nil.
      #
      #   Business case | Other business case
      #   ------------------------------
      #   Aggregator    | Aggregator
      #   Cooperation   |
      #                 | no_stakeholder
      #
      # For `no_stakeholder` an exception is made because there's a comparison
      # line but nothing to compare it to. It will return the financials but
      # with a difference of 0.0.
      #
      expect(compare.map{|t| t[:compare] }.select(&:nil?).count).to eq(1);
    end
  end
end
