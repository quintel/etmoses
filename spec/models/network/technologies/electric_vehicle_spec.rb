require 'rails_helper'

RSpec.describe Network::Technologies::ElectricVehicle do
  let(:capacity) { Float::INFINITY }
  let(:units)    { 1 }
  let(:volume)   { 3.0 }
  let(:opts)     { {} }

  let(:tech) do
    network_technology(build(
      :installed_ev,
      capacity: capacity, profile: profile,
      volume: volume, units: units
    ), profile.length, opts)
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

  context 'with stored energy 0.5 kWh' do
    before { tech.stored[0] = 0.5 }

    context 'and a profile value of zero' do
      let(:profile) { [0.0] * 8760 }

      context 'with storage on' do
        it 'has production of 0.5' do
          expect(tech.production_at(1)).to eq(0.5)
        end

        it 'has no mandatory consumption' do
          expect(tech.mandatory_consumption_at(1)).to be_zero
        end

        it 'has conditional consumption of 3.0' do
          expect(tech.conditional_consumption_at(1)).to eq(3.0)
        end
      end # with storage on

      context 'with storage off' do
        let(:opts) { { solar_storage: false } }

        it 'has production of 0.5' do
          expect(tech.production_at(1)).to eq(0.5)
        end

        it 'has mandatory consumption of 0.5' do
          expect(tech.mandatory_consumption_at(1)).to eq(0.5)
        end

        it 'has conditional consumption of 2.5' do
          expect(tech.conditional_consumption_at(1)).to eq(2.5)
        end
      end # with storage off
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

      context 'with two units' do
        let(:units) { 2 }

        it 'has production of 0.5' do
          expect(tech.production_at(1)).to eq(0.5)
        end

        it 'has mandatory consumption of 1.0' do
          # Mandatory consumption is dictated by the profile, which is already
          # scaled to the number of units.
          expect(tech.mandatory_consumption_at(1)).to eq(1.0)
        end

        it 'has conditional consumption equal to the volume * units' do
          # Total volume is 6.0; 1.0 assigned as mandatory. 5.0 remains.
          expect(tech.conditional_consumption_at(1)).to eq(5.0)
        end
      end # with two units
    end # and a profile value of 1.0

    context 'with a low-resolution curve' do
      let(:profile) { [0.0, 1.0] * 2190 }
      before { tech.stored[0] = 0.25 } # 0.5 kW in 2 hours is 0.25 kWf

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
          .from(0.5).to(1.5)
      end

      context 'with two units' do
        let(:units) { 2 }

        it 'has production of 0.5' do
          expect(tech.production_at(1)).to eq(0.5 / 2)
        end

        it 'has mandatory consumption of 1.0' do
          # Mandatory consumption is dictated by the profile, which is already
          # scaled to the number of units.
          expect(tech.mandatory_consumption_at(1)).to eq(1.0 / 2)
        end

        it 'has conditional consumption equal to the volume * units' do
          # volume is 6, minus 1.0 mandatory
          expect(tech.conditional_consumption_at(1)).to eq(5.0 / 2)
        end
      end # with two units
    end # with a low-resolution curve

    context 'with a high-resolution curve' do
      let(:profile) { [0.0, 1.0] * 17520 }
      before { tech.stored[0] = 2.0 } # 0.5 kWh in 0.25 hours is 2.0 kWf

      it 'increases volume in accordance with the curve resolution' do
        expect(tech.volume).to eq(volume * 4)
      end

      it 'has production of 2.0' do
        expect(tech.production_at(1)).to eq(2.0)
      end

      it 'has mandatory consumption of 4.0' do
        expect(tech.mandatory_consumption_at(1)).to eq(4.0)
      end

      it 'has conditional consumption of 8.0' do
        expect(tech.conditional_consumption_at(1)).to eq(8.0)
      end

      it 'scales additions to storage from kW to kWh' do
        expect { tech.store(1, 1.0) }
          .to change { tech.stored[1] }
          .from(4.0).to(5.0)
      end
    end # with a high-resolution curve

    context 'with a value of -1' do
      let(:profile) { [0.5, -1.0] * 4380 }

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

    context 'when disconnected, and an excess of storage' do
      let(:profile) { [0.2, -1.0, -1.0, 0.0] * 2190 }

      # The car is disconnected in a frame where the availability profile
      # specified that the car needed 0.2. There is therefore 0.3 kWf stored in
      # the car not needed for the next journey.

      context 'immediately after disconnection' do
        it 'has production of 0.3' do
          expect(tech.production_at(1)).to eq(0.3)
        end

        it 'has mandatory consumption of 0.3' do
          # 0.3 production and m.consumption cancel each other out; the car has
          # no load on the network, but preserves the amount stored.
          expect(tech.mandatory_consumption_at(1)).to eq(0.3)
        end

        it 'has no conditional consumption' do
          expect(tech.conditional_consumption_at(1)).to be_zero
        end

        it 'stores 0.3' do
          expect(tech.stored[1]).to eq(0.3)
        end
      end

      context 'part-way through disconnection' do
        before do
          # Compute the loads of the previous disconnection frames first.
          tech.production_at(1)
        end

        it 'has production of 0.3' do
          expect(tech.production_at(2)).to eq(0.3)
        end

        it 'has mandatory consumption of 0.3' do
          # 0.3 production and m.consumption cancel each other out; the car has
          # no load on the network, but preserves the amount stored.
          expect(tech.mandatory_consumption_at(2)).to eq(0.3)
        end

        it 'has no conditional consumption' do
          expect(tech.conditional_consumption_at(2)).to be_zero
        end

        it 'stores 0.3' do
          expect(tech.stored[2]).to eq(0.3)
        end
      end # part-way through disconnection

      context 'when reconnected' do
        before do
          # Compute the loads of the previous disconnection frames first.
          tech.production_at(1)
          tech.production_at(2)
        end

        it 'has production of 0.3' do
          expect(tech.production_at(3)).to eq(0.3)
        end

        it 'has no mandatory consumption' do
          # Profile has no required stored amount, therefore there is no
          # m.consumption.
          expect(tech.mandatory_consumption_at(3)).to be_zero
        end

        it 'has conditional consumption of 3.0' do
          # The EV may charge again.
          expect(tech.conditional_consumption_at(3)).to eq(3.0)
        end

        it 'stores nothing' do
          expect(tech.stored[3]).to be_zero
        end
      end # when reconnected

      context 'immediately after disconnection with storage off' do
        let(:opts) { super().merge(solar_storage: false) }

        it 'has production of 0.3' do
          expect(tech.production_at(1)).to eq(0.3)
        end

        it 'has mandatory consumption of 0.3' do
          expect(tech.mandatory_consumption_at(1)).to eq(0.3)
        end

        it 'has no conditional consumption' do
          expect(tech.conditional_consumption_at(1)).to be_zero
        end

        it 'stores 0.3' do
          expect(tech.stored[1]).to eq(0.3)
        end
      end
    end # when disconnected, and an excess of storage

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

        context 'with two units' do
          let(:units) { 2 }

          it 'has production of 0.5' do
            expect(tech.production_at(1)).to eq(0.5)
          end

          it 'has mandatory consumption of stored - capacity' do
            expect(tech.mandatory_consumption_at(1)).to be_within(1e-9).of(0.1)
          end

          it 'has conditional consumption equal to the volume * units' do
            # No capacity remains
            expect(tech.conditional_consumption_at(1)).to eq(0.8)
          end
        end # with two units
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
      end

      context 'and a profile value of 0.9' do
        let(:profile) { [0.0, 0.9] * 4380 }

        context 'with two units' do
          let(:units) { 2 }

          it 'has production of 0.5' do
            expect(tech.production_at(1)).to eq(0.5)
          end

          it 'has mandatory consumption of stored + capacity' do
            # Mandatory consumption is dictated by the profile, which is already
            # scaled to the number of units.
            expect(tech.mandatory_consumption_at(1)).to eq(0.9)
          end

          it 'has conditional consumption equal to the volume * units' do
            # No capacity remains
            expect(tech.conditional_consumption_at(1)).to be_zero
          end
        end # with two units
      end # and a profile value of 1.0
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
        build(:installed_ev, profile: profile, volume: 3.0),
        2, solar_storage: false, buffering_electric_car: false)
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
