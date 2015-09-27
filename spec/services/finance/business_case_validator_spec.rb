require 'rails_helper'

RSpec.describe Finance::BusinessCaseValidator do
  let(:validator) do
    Finance::BusinessCaseValidator.new(topology, market_model)
  end

  context 'when the topology case has all the applied-to stakeholders' do
    let(:topology)     { FactoryGirl.create(:topology_with_stakeholders) }
    let(:market_model) { FactoryGirl.create(:market_model) }

    it 'is valid' do
      expect(validator).to be_valid
    end
  end

  context 'when the topology is missing applied-to stakeholders' do
    let(:topology)     { FactoryGirl.create(:topology) }
    let(:market_model) { FactoryGirl.create(:market_model) }

    it 'is not valid' do
      expect(validator).to_not be_valid
    end
  end

  context 'when the topology stakeholders are defined out-of-order' do
    let(:topology) { FactoryGirl.create(:topology_with_stakeholders) }

    let(:market_model) do
      FactoryGirl.create(:market_model, interactions: [{
        "stakeholder_from"    => "customer",
        "stakeholder_to"      => "customer",
        "foundation"          => "connections",
        "applied_stakeholder" => "customer",
        "tariff_type"         => "fixed",
        "tariff"              => 5.2
      }, {
        "stakeholder_from"    => "customer",
        "stakeholder_to"      => "customer",
        "foundation"          => "connections",
        "applied_stakeholder" => "system operator",
        "tariff_type"         => "fixed",
        "tariff"              => 5.2
      }])
    end

    it 'is valid' do
      expect(validator).to be_valid
    end
  end

  context 'when the topology defines additional stakeholders' do
    let(:topology) { FactoryGirl.create(:topology_with_stakeholders) }

    let(:market_model) do
      FactoryGirl.create(:market_model, interactions: [{
        "stakeholder_from"    => "customer",
        "stakeholder_to"      => "customer",
        "foundation"          => "connections",
        "applied_stakeholder" => "customer",
        "tariff_type"         => "fixed",
        "tariff"              => 5.2
      }])
    end

    it 'is valid' do
      expect(validator).to be_valid
    end
  end

  context 'when the topology contains a non-string stakeholder' do
    let(:topology) { FactoryGirl.create(:topology_with_stakeholders) }
    let(:market_model) { FactoryGirl.create(:market_model) }

    before do
      topology.graph[:stakeholder] = 123
    end

    it 'is valid' do
      expect(validator).to be_valid
    end
  end

  context 'when the topology contains an empty stakeholder' do
    let(:topology) { FactoryGirl.create(:topology_with_stakeholders) }
    let(:market_model) { FactoryGirl.create(:market_model) }

    before do
      topology.graph[:stakeholder] = nil
    end

    it 'is valid' do
      expect(validator).to be_valid
    end
  end
end
