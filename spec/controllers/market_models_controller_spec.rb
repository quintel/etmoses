require 'rails_helper'

RSpec.describe MarketModelsController do
  let(:user){ FactoryGirl.create(:user) }
  let!(:sign_in_user){ sign_in(user) }

  it 'visits index path' do
    get :index

    expect(response.status).to eq(200)
  end

  it 'visits new market model view' do
    get :new

    expect(response.status).to eq(200)
  end
end
