require 'rails_helper'

RSpec.describe BusinessCase do
  describe '.freeform' do
    let(:business_case){ FactoryGirl.create(:business_case, financials: financials) }

    describe 'no freeform' do
      let(:financials){ JSON.dump([{"aggregator" =>[1]}]) }

      it "creates a new freeform row of a business case" do
        expect(business_case.freeform).to eq({'freeform' => [nil]})
      end
    end

    describe 'freeform' do
      let(:financials){ JSON.dump([{"aggregator" =>[1]}, {'freeform' => [0]}]) }

      it "grabs the existing freeform row of a business case" do
        expect(business_case.freeform).to eq({'freeform' => [0]})
      end
    end
  end
end
