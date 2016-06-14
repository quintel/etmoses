require 'rails_helper'

RSpec.describe LoadCalculationsController do
  let(:user) { FactoryGirl.create(:user) }
  let(:testing_ground) { FactoryGirl.create(:testing_ground, user: user) }
  let!(:sign_in_user){ sign_in(user) }

  it "succesfully visits the heat path" do
    post :heat, testing_ground_id: testing_ground.id

    expect(response).to be_success
  end
end
