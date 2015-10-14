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

    expect(compare).to eq([
      { :stakeholder=>"aggregator",
        :incoming=>0,
        :outgoing=>1,
        :freeform=>nil,
        :total=>-1,
        :compare=>{
          :stakeholder=>"aggregator",
          :incoming=>3,
          :outgoing=>2,
          :freeform=>nil,
          :total=>1
        }
      },
      { :stakeholder=>"cooperation",
        :incoming=>1,
        :outgoing=>0,
        :freeform=>nil,
        :total=>1,
        :compare=>{
          :stakeholder=>"cooperation",
          :incoming=>1,
          :outgoing=>3,
          :freeform=>nil,
          :total=>-2
        }
      }])
  end

  context 'when a business case is missing a stakeholder' do
    let(:other_financials){
      [ {"aggregator" =>[1, 3]} ]
    }

    it "compares two business cases" do
      compare = Finance::BusinessCaseComparator.new(
        business_case, other_business_case
      ).compare

      expect(compare).to eq([
        { :stakeholder=>"aggregator", :incoming=>0, :outgoing=>1, :freeform=>nil, :total=>-1,
         :compare=>{:stakeholder=>"aggregator", :incoming=>3, :outgoing=>1, :freeform=>nil, :total=>2}},
        { :stakeholder=>"cooperation", :incoming=>1, :outgoing=>0, :freeform=>nil, :total=>1, :compare=>nil}
      ]);
    end
  end

  context 'when a business case is missing a stakeholder' do
    let(:other_financials){
      [ {"no_stakeholder" =>[1, 3]}, {"aggregator" =>[1, 3]}]
    }

    it "compares two business cases" do
      compare = Finance::BusinessCaseComparator.new(
        business_case, other_business_case
      ).compare

      expect(compare).to eq([
        { :stakeholder=>"aggregator", :incoming=>0, :outgoing=>1, :freeform=>nil, :total=>-1,
          :compare=>{:stakeholder=>"aggregator", :incoming=>1, :outgoing=>6, :freeform=>nil, :total=>-5}},
        { :stakeholder=>"cooperation", :incoming=>1, :outgoing=>0, :freeform=>nil, :total=>1, :compare=>nil},
        { :stakeholder => "no_stakeholder", :compare=>{:stakeholder=>"no_stakeholder", :incoming=>3, :outgoing=>2, :freeform=>nil, :total=>1}}
      ]);
    end
  end
end
