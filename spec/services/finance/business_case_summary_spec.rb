require 'rails_helper'

RSpec.describe Finance::BusinessCaseSummary do
  let(:financials){
    [ {"aggregator"      => [0,   nil, nil,     nil, nil, nil, nil]},
      {"cooperation"     => [nil, 0,   nil,     nil, nil, nil, nil]},
      {"customer"        => [nil, nil, 0,       nil, nil, nil, nil]},
      {"government"      => [nil, nil, nil,     0,   nil, nil, nil]},
      {"producer"        => [nil, nil, nil,     nil, 0,   nil, nil]},
      {"supplier"        => [nil, nil, nil,     nil, nil, 0,   nil]},
      {"system operator" => [nil, nil, 44150.4, nil, nil, nil, 9998]},
      {"freeform"        => { "system operator" => 0 } }
    ]
  }

  let(:business_case){ FactoryGirl.create(:business_case, financials: financials) }

  let(:summarized) {
    Finance::BusinessCaseSummary.new(business_case).summarize
  }

  it "gives the business case summary for customer" do
    expect(summarized.detect{ |t| t[:stakeholder] == 'customer' }).to eq({
      :stakeholder=>"customer",
      :incoming=>nil,
      :outgoing=>44150.4,
      :freeform=>nil,
      :total=>-44150.4
    })
  end

  it "gives the business case summary for system operator" do
    expect(summarized.detect{ |t| t[:stakeholder] == 'system operator' }).to eq({
      :stakeholder=>"system operator",
      :incoming=>44150.4,
      :outgoing=>9998,
      :freeform=>0,
      :total=>34152.4
    })
  end

  context 'with 20.0 freeform cost on the system operator' do
    let(:financials) do
      super().tap do |fin|
        fin.detect { |f| f.keys.first == 'freeform' }['freeform']['system operator'] = 20.0
      end
    end

    it 'applies a 20.0 cost to the system operator' do
      so = summarized.detect{ |t| t[:stakeholder] == 'system operator' }
      expect(so[:freeform]).to eq(-20.0)
    end

    it 'reduces the stakeholder total by 20' do
      so = summarized.detect{ |t| t[:stakeholder] == 'system operator' }
      expect(so[:total]).to eq(34152.4 - 20)
    end
  end
end
