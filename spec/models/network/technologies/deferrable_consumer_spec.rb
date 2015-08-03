require 'rails_helper'

RSpec.describe Network::Technologies::DeferrableConsumer do
  let(:capacity) { 5.0 }

  let(:tech) do
    network_technology(build(
      :installed_deferred, profile: profile, capacity: capacity
    ), 8760, curve_type: :flex)
  end

  context 'with no stored amount' do
    let(:profile) { [0.0] * 8760 }

    it 'defaults to having no deferred loads' do
      expect(tech.conditional_consumption_at(0)).to be_zero
    end
  end
end
