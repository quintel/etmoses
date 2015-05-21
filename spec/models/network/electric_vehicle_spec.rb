require 'rails_helper'

RSpec.describe Network::ElectricVehicle do
  let(:capacity) { Float::INFINITY }

  let(:tech) do
    network_technology(build(
      :installed_ev, capacity: capacity, profile: profile, volume: 3.0
    ))
  end

  context 'in frame 0' do
    let(:profile) { [0.0] * 8760 }

    it 'has no production' do
      expect(tech.production_at(0)).to be_zero
    end

    it 'has no mandatory consumption' do
      expect(tech.mandatory_consumption_at(0)).to be_zero
    end

    it 'has conditional consumption equal to the volume' do
      expect(tech.conditional_consumption_at(0)).to eq(3.0)
    end
  end # in frame 0

  context 'with stored energy 0.5' do
    before { tech.stored[0] = 0.5 }

    context 'and a profile value of zero' do
      let(:profile) { [0.0] * 8760 }

      it 'has production of 0.5' do
        expect(tech.production_at(1)).to eq(0.5)
      end

      it 'has no mandatory consumption' do
        expect(tech.mandatory_consumption_at(1)).to be_zero
      end

      it 'has conditional consumption of 3.0' do
        expect(tech.conditional_consumption_at(1)).to eq(3.0)
      end
    end # and a profile value of zero

    context 'and a profile value of 1.0' do
      let(:profile) { [0.0, 1.0] * 4380 }

      it 'has production of 0.5' do
        expect(tech.production_at(1)).to eq(0.5)
      end

      it 'has mandatory consumption of 1.0' do
        expect(tech.mandatory_consumption_at(1)).to eq(1.0)
      end

      it 'has conditional consumption of 2.0' do
        expect(tech.conditional_consumption_at(1)).to eq(2.0)
      end

      it 'allows additions to storage' do
        expect { tech.store(1, 2.0) }
          .to change { tech.stored[1] }
          .from(1.0).to(3.0)
      end
    end # and a profile value of 1.0

    context 'with a low-resolution curve' do
      let(:profile) { [0.0, 1.0] * 2190 }

      it 'scales production from kWh to kW' do
        expect(tech.production_at(1)).to eq(0.5 / 2)
      end

      it 'scales mandatory consumption from kWh to kW' do
        expect(tech.mandatory_consumption_at(1)).to eq(1.0 / 2)
      end

      it 'scales conditional consumption from kWh to kW' do
        expect(tech.conditional_consumption_at(1)).to eq(2.0 / 2)
      end

      it 'scales additions to storage from kW to kWh' do
        expect { tech.store(1, 1.0) }
          .to change { tech.stored[1] }
          .from(1.0).to(3.0) # 1kW delivered over 2 hours is 2kWh
      end
    end # with a low-resolution curve

    context 'with a value of -1' do
      let(:profile) { [0.0, -1.0] * 4380 }

      it 'has production of zero' do
        expect(tech.production_at(1)).to be_zero
      end

      it 'has no mandatory consumption' do
        expect(tech.mandatory_consumption_at(1)).to be_zero
      end

      it 'has no conditional consumption' do
        expect(tech.conditional_consumption_at(1)).to be_zero
      end
    end # with stored energy of 0.5, and with a profile 1.0

    context 'with capacity of 0.2' do
      let(:capacity) { 0.2 }

      context 'and a profile value of zero' do
        let(:profile) { [0.0] * 8760 }

        it 'has production of 0.5' do
          expect(tech.production_at(1)).to eq(0.5)
        end

        it 'has mandatory consumption of stored - capacity' do
          expect(tech.mandatory_consumption_at(1)).to eq(0.3)
        end

        it 'has conditional consumption of 0.4' do
          expect(tech.conditional_consumption_at(1)).to be_within(1e-9).of(0.4)
        end
      end # and a profile value of zero

      context 'and a profile value of 0.8' do
        let(:profile) { [0.0, 0.8] * 4380 }

        it 'has production of 0.5' do
          expect(tech.production_at(1)).to eq(0.5)
        end

        it 'has mandatory consumption of stored + capacity' do
          expect(tech.mandatory_consumption_at(1)).to eq(0.7)
        end

        it 'has conditional consumption of zero' do
          expect(tech.conditional_consumption_at(1)).to be_zero
        end
      end # and a profile value of 0.8
    end # with capacity of 0.2

    context 'with capacity of 5.0' do
      let(:capacity) { 5.0 }

      context 'and a profile value of 0' do
        let(:profile) { [0.0] * 8760 }

        it 'has production of 0.5' do
          expect(tech.production_at(1)).to eq(0.5)
        end

        it 'has no mandatory consumption' do
          expect(tech.mandatory_consumption_at(1)).to be_zero
        end

        it 'has conditional consumption of 3.0' do
          expect(tech.conditional_consumption_at(1)).to eq(3.0)
        end
      end # and a profile value 0

      context 'and a profile value of 0.8' do
        let(:profile) { [0.0, 0.8] * 4380 }

        it 'has production of 0.5' do
          expect(tech.production_at(1)).to eq(0.5)
        end

        it 'has mandatory consumption of 0.8' do
          expect(tech.mandatory_consumption_at(1)).to eq(0.8)
        end

        it 'has conditional consumption 2.2' do
          expect(tech.conditional_consumption_at(1)).to eq(2.2)
        end
      end # and a profile value of 8

      context 'and a profile value of -1' do
        let(:profile) { [0.0, -1.0] * 4380 }

        it 'has no production' do
          expect(tech.production_at(1)).to be_zero
        end

        it 'has no mandatory consumption' do
          expect(tech.mandatory_consumption_at(1)).to be_zero
        end

        it 'has no conditional consumption' do
          expect(tech.conditional_consumption_at(1)).to be_zero
        end
      end # and a profile value of -1
    end # with capacity of 5.0
  end # with a profile

  context 'when the previous frame was a disconnection' do
    let(:profile) { [-1.0, 0.0] * 4380 }

    it 'has no production' do
      expect(tech.production_at(1)).to be_zero
    end

    it 'has no mandatory consumption' do
      expect(tech.mandatory_consumption_at(1)).to be_zero
    end

    it 'has conditional consumption equal to the volume' do
      expect(tech.conditional_consumption_at(1)).to eq(3.0)
    end
  end # when the previous frame was a disconnection

  context 'when disabled' do
    let(:profile) { [0.0] * 8760 }

    let(:tech) do
      network_technology(
        build(:installed_ev, profile: profile, volume: 3.0), 2, storage: false)
    end

    it 'becomes a consumer' do
      expect(tech).to be_consumer
    end

    context 'with a negative profile value in frame 0' do
      let(:profile) { [-1.0, 0.0] * 4380 }

      it 'has no production in frame 0' do
        expect(tech.production_at(0)).to be_zero
      end

      it 'has no mandatory consumption in frame 0' do
        expect(tech.mandatory_consumption_at(0)).to be_zero
      end

      it 'has no conditional consumption in frame 0' do
        expect(tech.conditional_consumption_at(0)).to be_zero
      end

      it 'has no production in frame 1' do
        expect(tech.production_at(1)).to be_zero
      end

      it 'has no mandatory consumption in frame 1' do
        expect(tech.mandatory_consumption_at(1)).to be_zero
      end

      it 'has no conditional consumption in frame 1' do
        expect(tech.conditional_consumption_at(1)).to be_zero
      end
    end # with a negative profile value in frame 0

    context 'and a profile value of zero' do
      let(:profile) { [0.0] * 8760 }

      it 'has no production' do
        expect(tech.production_at(1)).to be_zero
      end

      it 'has no mandatory consumption' do
        expect(tech.conditional_consumption_at(1)).to be_zero
      end

      it 'has no conditional consumption' do
        expect(tech.conditional_consumption_at(1)).to be_zero
      end
    end # and a profile value of zero

    context 'and a profile value of 1.0' do
      let(:profile) { [0.0, 1.0] * 4380 }

      it 'has no production' do
        expect(tech.production_at(1)).to be_zero
      end

      it 'has mandatory consumption of 1.0' do
        expect(tech.mandatory_consumption_at(1)).to eq(1.0)
      end

      it 'has no conditional consumption' do
        expect(tech.conditional_consumption_at(1)).to be_zero
      end
    end # and a profile value of 1.0

    context 'with a value of -1' do
      let(:profile) { [0.0, -1.0] * 4380 }

      it 'has production of zero' do
        expect(tech.production_at(1)).to be_zero
      end

      it 'has no mandatory consumption' do
        expect(tech.mandatory_consumption_at(1)).to be_zero
      end

      it 'has no conditional consumption' do
        expect(tech.conditional_consumption_at(1)).to be_zero
      end
    end # with a profile -1.0
  end # when disabled
end
