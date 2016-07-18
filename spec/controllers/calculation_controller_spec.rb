require 'rails_helper'

RSpec.describe CalculationController do
  let(:user) { FactoryGirl.create(:user) }
  let(:testing_ground) { FactoryGirl.create(:testing_ground, user: user) }
  let!(:sign_in_user){ sign_in(user) }

  it "succesfully visits the heat path" do
    post :heat, id: testing_ground.id,
      calculation: { range_start: 0, range_end: 672 }

    expect(response).to be_success
  end

  context 'with no calculation options' do
    it "raises an error" do
      expect { post :heat, id: testing_ground.id }
        .to raise_error('param is missing or the value is empty: calculation')
    end
  end

  describe "#gas" do
    let!(:gas_asset_list) {
      FactoryGirl.create(:gas_asset_list, testing_ground: testing_ground)
    }

    it "succesfully visits the gas path" do
      post :gas, id: testing_ground.id,
        calculation: { range_start: 0, range_end: 672 }

      expect(response).to be_success
    end
  end
end
