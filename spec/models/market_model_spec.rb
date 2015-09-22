require 'rails_helper'

RSpec.describe MarketModel do
  it { expect(subject).to validate_presence_of(:name) }
end
