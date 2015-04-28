require 'rails_helper'

RSpec.describe User do
  it 'activates a user' do
    user = FactoryGirl.create(:user)
    user.activate!

    expect(user.activated?).to eq(true)
  end
end
