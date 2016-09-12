require 'rails_helper'

RSpec.describe TestingGround::Destroyer do
  let(:destroy!) { described_class.run(les) }

  context 'the topology' do
    let!(:topology) { create(:topology, user: create(:user)) }

    let!(:les) do
      create(:testing_ground, user: topology.user, topology: topology)
    end

    context '- with no other uses -' do
      it 'is deleted' do
        expect { destroy! }.to change { Topology.count }.by(-1)
      end
    end

    context '- in use by the owner -' do
      let!(:other) do
        create(
          :testing_ground,
          topology: les.topology,
          user: les.user
        )
      end

      it 'does not change the topology owner' do
        expect { destroy! }.not_to change { topology.reload.user_id }
      end

      it 'does not delete the topology' do
        expect { destroy! }.not_to change { Topology.count }
      end

      it 'does not change the topology on other testing grounds' do
        expect { destroy! }.not_to change { other.topology_id }
      end
    end

    context '- in use by other users not the owner -' do
      let!(:other) do
        create(:testing_ground, topology: les.topology)
      end

      it 'is reassigned to the orphan' do
        expect { destroy! }.to change { topology.reload.user_id }
      end

      it 'does not delete the topology' do
        expect { destroy! }.not_to change { Topology.count }
      end

      it 'does not change the topology on other testing grounds' do
        expect { destroy! }.not_to change { other.topology_id }
      end
    end

    context 'when the topology is owned by someone else' do
      let!(:les) do
        create(:testing_ground, topology: topology)
      end

      it 'does not delete the topology' do
        expect { destroy! }.not_to change { Topology.count }
      end

      it 'does not reassign ownership of the topology' do
        expect { destroy! }.not_to change { topology.reload.user_id }
      end
    end
  end # the topology

  context 'the market model' do
    let!(:market_model) { create(:market_model, user: create(:user)) }

    let!(:les) do
      create(
        :testing_ground,
        user: market_model.user,
        market_model: market_model
      )
    end

    context '- with no other uses -' do
      it 'is deleted' do
        expect { destroy! }.to change { MarketModel.count }.by(-1)
      end
    end

    context '- in use by the owner -' do
      let!(:other) do
        create(
          :testing_ground,
          market_model: les.market_model,
          user: les.user
        )
      end

      it 'does not change the MM owner' do
        expect { destroy! }.not_to change { market_model.reload.user_id }
      end

      it 'does not delete the market model' do
        expect { destroy! }.not_to change { MarketModel.count }
      end

      it 'does not change the market model on other testing grounds' do
        expect { destroy! }.not_to change { other.market_model_id }
      end
    end

    context '- in use by other users not the owner -' do
      let!(:other) do
        create(:testing_ground, market_model: les.market_model)
      end

      it 'is reassigned to the orphan' do
        expect { destroy! }.to change { market_model.reload.user_id }
      end

      it 'does not delete the market model' do
        expect { destroy! }.not_to change { MarketModel.count }
      end

      it 'does not change the market model on other testing grounds' do
        expect { destroy! }.not_to change { other.market_model_id }
      end
    end

    context 'when the market model is owned by someone else' do
      let!(:les) do
        create(:testing_ground, market_model: market_model)
      end

      it 'does not delete the market model' do
        expect { destroy! }.not_to change { MarketModel.count }
      end

      it 'does not reassign ownership of the market model' do
        expect { destroy! }.not_to change { market_model.reload.user_id }
      end
    end
  end # the market model
end
