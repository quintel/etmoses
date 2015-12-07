require 'rails_helper'

RSpec.describe Network::Technologies::Buffer do
  context 'with a storage volume of 10 and capacity of 5' do
    let(:capacity)      { 5.0 }
    let(:volume)        { 50.0 }
    let(:performance)   { 1.0 }

    let(:tech) do
      tech = network_technology(
        build(
          :installed_heat_pump, profile: profile,
          capacity: capacity, volume: volume,
          performance_coefficient: performance,
          buffer: 'one'
        ), 8760,
        buffering_space_heating: true
      )

      dprofile  = Network::DepletingCurve.new(profile)
      composite = Network::Technologies::Composite.new(
        Float::INFINITY, volume, dprofile)

      composite.add(tech)
    end

    context 'with nothing stored' do
      context 'and no required load' do
        let(:profile) { [0.0] * 8760 }

        it 'has no production' do
          expect(tech.production_at(1)).to be_zero
        end

        it 'has no mandatory consumption' do
          expect(tech.mandatory_consumption_at(1)).to be_zero
        end

        it 'has conditional consumption equal to the capacity' do
          expect(tech.conditional_consumption_at(1)).to eq(5)
        end

        it 'stores nothing' do
          expect(tech.stored[1]).to be_zero
        end
      end

      # with nothing stored
      describe 'and use of 2.5' do
        let(:profile) { [0.0, 2.5] * 4380 }

        context 'assigned nothing' do
          it 'has no production' do
            expect(tech.production_at(1)).to be_zero
          end

          it 'has mandatory consumption of 2.5' do
            expect(tech.mandatory_consumption_at(1)).to eq(2.5)
          end

          it 'has conditional consumption of 2.5' do
            expect(tech.conditional_consumption_at(1)).to eq(2.5)
          end

          it 'stores nothing' do
            expect(tech.stored[1]).to be_zero
          end

          # with nothing stored and use of 2.5
          context 'with a performance coefficient of 4.0' do
            let(:performance) { 4.0 }

            it 'has mandatory consumption of 0.625' do
              expect(tech.mandatory_consumption_at(1)).to eq(0.625)
            end

            it 'has conditional consumption of 0.625' do
              expect(tech.conditional_consumption_at(1)).to eq(0.625)
            end
          end
        end

        # with nothing stored and use of 2.5
        context 'assigned 5.0 conditional by the calculator' do
          before { tech.store(1, 5.0) }

          it 'stores 5.0' do
            expect(tech.stored[1]).to eq(5.0)
          end

          # with nothing stored and use of 2.5, assigned 5.0 conditional
          context 'and a performance coefficient of 4.0' do
            let(:performance) { 4.0 }

            it 'stores 20.0' do
              expect(tech.stored[1]).to eq(20.0)
            end
          end
        end

        # with nothing stored and use of 2.5
        context 'assigned 1.0 conditional by the calculator' do
          before { tech.store(1, 1.0) }

          it 'stores 1.0' do
            expect(tech.stored[1]).to eq(1.0)
          end
        end
      end # and use of 2.5
    end # with nothing stored

    context 'with 2.5 stored' do
      before { tech.stored[0] = 2.5 }

      context 'and no use' do
        let(:profile) { [0.0] * 8760 }

        it 'has no production' do
          expect(tech.production_at(1)).to be_zero
        end

        it 'has no mandatory consumption' do
          expect(tech.mandatory_consumption_at(1)).to be_zero
        end

        it 'has conditional consumption of 5.0' do
          expect(tech.conditional_consumption_at(1)).to eq(5)
        end

        it 'has 2.5 remaining storage' do
          expect(tech.stored[1]).to eq(2.5)
        end
      end # and no use

      # with 2.5 stored
      context 'and a use of 1.5' do
        let(:profile) { [0.0, 1.5] * 4380 }

        context 'assigned nothing' do
          it 'has no production' do
            expect(tech.production_at(1)).to be_zero
          end

          it 'has no mandatory consumption' do
            expect(tech.mandatory_consumption_at(1)).to be_zero
          end

          it 'has conditional consumption of 5.0' do
            expect(tech.conditional_consumption_at(1)).to eq(5)
          end

          it 'has 1.0 remaining storage' do
            expect(tech.stored[1]).to eq(1)
          end
        end

        # with 2.5 stored and use of 1.5
        context 'and a capacity of 0.5' do
          let(:capacity) { 0.5 }

          it 'has no production' do
            expect(tech.production_at(1)).to be_zero
          end

          it 'has no mandatory consumption' do
            expect(tech.mandatory_consumption_at(1)).to be_zero
          end

          it 'has conditional consumption of 0.5' do
            expect(tech.conditional_consumption_at(1)).to eq(0.5)
          end

          it 'has 1.0 remaining storage' do
            expect(tech.stored[1]).to eq(1)
          end
        end # and a capacity of 0.5

        # with 2.5 stored and use of 1.5
        context 'and a capacity of 2.0' do
          let(:capacity) { 2.0 }

          it 'has no production' do
            expect(tech.production_at(1)).to be_zero
          end

          it 'has no mandatory consumption' do
            expect(tech.mandatory_consumption_at(1)).to be_zero
          end

          it 'has conditional consumption of 2.0' do
            expect(tech.conditional_consumption_at(1)).to eq(2)
          end

          it 'has 1.0 remaining storage' do
            expect(tech.stored[1]).to eq(1)
          end
        end # and a capacity of 2.0
      end # and a required load of 1.5

      # with 2.5 stored
      context 'and a use of 2.5' do
        let(:profile) { [0.0, 2.5] * 4380 }

        it 'has no production' do
          expect(tech.production_at(1)).to be_zero
        end

        it 'has no mandatory consumption' do
          expect(tech.mandatory_consumption_at(1)).to be_zero
        end

        it 'has conditional consumption of 5' do
          expect(tech.conditional_consumption_at(1)).to eq(5)
        end

        it 'has no remaining storage' do
          expect(tech.stored[1]).to be_zero
        end
      end # and a required load of 2.5

      # with 2.5 stored
      context 'and a use of 5.0' do
        let(:profile) { [0.0, 5.0] * 4380 }

        it 'has no production' do
          expect(tech.production_at(1)).to be_zero
        end

        it 'has mandatory consumption of 2.5' do
          expect(tech.mandatory_consumption_at(1)).to eq(2.5)
        end

        it 'has conditional consumption of 2.5' do
          expect(tech.conditional_consumption_at(1)).to eq(2.5)
        end

        it 'has no remaining storage' do
          expect(tech.stored[1]).to be_zero
        end
      end # and a use of 5.0
    end # with 2.5 stored

    context 'with a storage volume of 3.0 and use of 2.5' do
      let(:volume)  { 3.0 }
      let(:profile) { [0.0, 2.5] * 4380 }

      # with a storage volume of 3.0 and use of 2.5
      context 'with a performance coefficient of 4.0' do
        let(:performance) { 4.0 }

        it 'has mandatory consumption of 0.625' do
          expect(tech.mandatory_consumption_at(1)).to eq(0.625)
        end

        pending 'has conditional consumption of 0.625' do
          # Buffer should be able to satisfy demand, *and* refill the buffer.
          expect(tech.conditional_consumption_at(1)).to eq(0.625)
        end
      end
    end
  end # with a storage volume of 50

  context 'when disabled' do
    let(:profile) { [0.0] * 8760 }

    let(:tech) do
      network_technology(
        build(
          :installed_heat_pump, profile: profile,
          capacity: 5.0, volume: 50.0, buffer: 'one'
        ), 8760,
        buffering_space_heating: false
      )
    end

    it 'becomes a Generic' do
      expect(tech).to be_a(Network::Technologies::Generic)
    end

    context 'and a profile value of zero' do
      let(:avail_profile) { [0.0] * 8760 }

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
  end # when disabled
end
