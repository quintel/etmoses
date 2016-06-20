require 'rails_helper'

RSpec.describe Network::Technologies::ConservingProducer do
  let(:installed) do
    InstalledTechnology.new(capacity: -1.5)
  end

  let(:tech) do
    network_technology(
      installed, profile,
      behavior: 'conserving',
      strategies: options
    )
  end

  describe "default profile" do
    let(:profile){ [-200.0] }
    let(:options){ { capping_solar_pv: false, capping_fraction: '0.5' } }

    it "expects production_at to be" do
      expect(tech.production_at(0)).to eq(200.0)
    end
  end

  describe "with solar capping" do
    let(:profile){ [-1.0, -1.5] }
    let(:options){ { capping_solar_pv: true, capping_fraction: '0.5' } }

    it 'expects -200.0 not to be capped at all' do
      expect(tech.conservable_production_at(0)).to eq(0.25)
    end

    it 'expects capping to fix the congestion' do
      expect(tech.conservable_production_at(1)).to eq(0.75)
    end
  end
end
