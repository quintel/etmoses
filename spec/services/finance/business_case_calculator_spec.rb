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
        expect(business_case.stakeholders).to eq(["customer", "system operator"])
      end

      it "determines the value of the business case" do
        price = business_case.send(:row, "customer", "customer")

        # 1 frame per hour (8760)
        # year-round loads of 0.9 and 3.3
        # 0.5 eur per unit
        expect(price).to eq(8760.0 * 0.5 * (0.9 + 3.3))
      end

      it "determines the rows of the business case" do
        expect(business_case).to receive(:stakeholders).twice.and_return(["customer"])

        expect(business_case.rows).to eq([{
          "customer" => [8760.0 * 0.5 * (0.9 + 3.3)]
        }])
      end
    end

    describe "calculation advanced" do
      let(:market_model_interactions){ MarketModels::Default.advanced }

      it "determines the correct headers" do
        expect(business_case.stakeholders).to eq(["customer", "government",
                                                  "supplier", "system operator"])
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
    let(:market_model_interactions){
      [{ 'stakeholder_from'    => 'customer',
         'stakeholder_to'      => 'system operator',
         'foundation'          => 'kwh_consumed',
         'tariff'              => '0.6',
         'applied_stakeholder' => 'system operator' }]
    }

    let(:market_model){
      FactoryGirl.create(:market_model, interactions: market_model_interactions)
    }

    let(:topology){
      FactoryGirl.create(:topology_with_financial_information)
    }

    let(:technology_profile){
      { "hh1" => [{ "name"                                => "Residential PV panel",
                    "type"                                => "households_solar_pv_solar_radiation",
                    "profile"                             => nil,
                    "profile_key"                         => nil,
                    "capacity"                            => -1.5,
                    "units"                               => 1,
                    "initial_investment"                  => 10,
                    "technical_lifetime"                  => 1,
                    "performance_coefficient"             => 1.0,
                    "concurrency"                         => "max" },
                  { "name"                                => "Electric vehicle",
                    "type"                                => "households_solar_pv_solar_radiation",
                    "profile"                             => nil,
                    "profile_key"                         => nil,
                    "capacity"                            => -1.5,
                    "units"                               => 1,
                    "initial_investment"                  => nil,
                    "technical_lifetime"                  => nil,
                    "full_load_hours"                     => nil,
                    "om_costs_per_year"                   => 5.5,
                    "om_costs_per_full_load_hour"         => nil,
                    "om_costs_for_ccs_per_full_load_hour" => nil,
                    "performance_coefficient"             => 1.0,
                    "concurrency"                         => "max" },
                  { "name"                                => "Electric vehicle",
                    "type"                                => "households_solar_pv_solar_radiation",
                    "profile"                             => nil,
                    "profile_key"                         => nil,
                    "capacity"                            => -1.5,
                    "units"                               => 2,
                    "initial_investment"                  => nil,
                    "technical_lifetime"                  => nil,
                    "full_load_hours"                     => 0,
                    "om_costs_per_year"                   => 5.5,
                    "om_costs_per_full_load_hour"         => 25.0,
                    "om_costs_for_ccs_per_full_load_hour" => nil,
                    "performance_coefficient"             => 1.0,
                    "concurrency"                         => "max" }
        ]
      }
    }

    let(:testing_ground){
      FactoryGirl.create(:testing_ground,
        technology_profile: technology_profile,
        market_model: market_model, topology: topology)
    }

    let(:business_case){ Finance::BusinessCaseCalculator.new(testing_ground) }

    it "determines the initial investments for the stakeholders" do
      expect(business_case.rows.last['system operator'].last).to eq(11000.0)
      expect(business_case.rows[1]['customer'][1]).to eq(26.5)
    end
  end
end
