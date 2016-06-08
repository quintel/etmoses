require 'rails_helper'

RSpec.describe Finance::BusinessCaseCalculator do
  describe "basic business case" do
    let(:market_model){
      FactoryGirl.create(:market_model, interactions: market_model_interactions)
    }

    let(:topology){
      FactoryGirl.create(:topology_with_stakeholders)
    }

    let(:testing_ground){
      FactoryGirl.create(:testing_ground, market_model: market_model, topology: topology)
    }

    let(:business_case){ Finance::BusinessCaseCalculator.new(testing_ground) }

    describe "calculation" do
      let(:market_model_interactions){ MarketModels::Default.interactions }

      it "determines the correct headers" do
        expect(business_case.instance_variable_get("@stakeholders")).to eq([
          "customer", "system operator"
        ])
      end

      it "determines the value of the business case" do
        price = business_case.send(:row, "customer", "customer")

        # 1 frame per hour (8760)
        # year-round loads of 0.9 and 3.3
        # 0.5 eur per unit
        expect(price).to eq(8760.0 * 0.5 * (0.9 + 3.3))
      end

      it "determines the rows of the business case" do
        expect(business_case.rows).to eq([
          { "customer" => [8760.0 * 0.5 * (0.9 + 3.3), nil] },
          { "system operator"=>[nil, 0.0] }
        ])
      end
    end

    describe "calculation advanced" do
      let(:market_model_interactions){ MarketModels::Default.advanced }

      it "determines the correct headers" do
        expect(business_case.fetch_stakeholders).to eq([
          "customer", "government", "supplier", "system operator"
        ])
      end

      it "financials" do
        expect(business_case.rows).to eq([
          {"customer"       =>[0.0, nil, nil, nil]},
          {"government"     =>[nil, 0.0, nil, 18396.0]},
          {"supplier"       =>[18396.0, nil, 0.0, nil]},
          {"system operator"=>[nil, nil, nil, 0.0]}
        ])
      end
    end
  end

  describe "with the default initial investments" do
    let(:market_model_interactions) {
      [{ 'stakeholder_from'    => 'customer',
         'stakeholder_to'      => 'system operator',
         'foundation'          => 'kwh_consumed',
         'tariff'              => '0.6',
         'applied_stakeholder' => 'system operator' }]
    }

    let(:technology_profile) {
      YAML.load(File.read(
        "#{Rails.root}/spec/fixtures/data/technology_profiles/solar_panels.yml"
      ))
    }

    let(:testing_ground) {
      FactoryGirl.create(:testing_ground,
        technology_profile: technology_profile,
        market_model: FactoryGirl.create(:market_model, interactions: market_model_interactions),
        topology: FactoryGirl.create(:topology_with_financial_information)
      )
    }

    let!(:create_gas_asset_list) {
      FactoryGirl.create(:gas_asset_list,
        testing_ground: testing_ground,
        asset_list: YAML.load(File.read(
          "#{Rails.root}/spec/fixtures/data/gas_asset_lists/default_pipes_connectors.yml"
        ))
      )
    }

    let!(:create_heat_source_list) {
      FactoryGirl.create(:heat_source_list,
        testing_ground: testing_ground,
        asset_list: YAML.load(File.read(
          "#{Rails.root}/spec/fixtures/data/heat_source_lists/default.yml"
        ))
      )
    }

    let(:business_case) { Finance::BusinessCaseCalculator.new(testing_ground) }

    it "determines the initial investments for the stakeholders" do
      expect(business_case.rows.last['system operator'].last).to eq(22100.0)
      expect(business_case.rows[1]['customer'][1]).to eq(10729.5)
    end
  end
end
