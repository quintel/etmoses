require 'rails_helper'

RSpec.describe Network::Technologies::LegacyBuffer do
  context 'with a storage volume of 10' do
    let(:capacity) { 5.0 }
    let(:volume)   { 50.0 }

    let(:tech) do
      network_technology(
        build(
          :installed_heat_pump, profile: avail_profile,
          capacity: capacity, volume: volume
        ), 8760,
        buffering_space_heating: true,
        additional_profile: use_profile
      )
    end

    context 'with nothing stored' do
      context 'and no required load' do
        let(:avail_profile) { [0.0] * 8760 }
        let(:use_profile)   { [0.0] * 8760 }

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

      describe 'and use of 2.5' do
        let(:avail_profile) { [0.0] * 8760 }
        let(:use_profile)   { [0.0, 2.5] * 4380 }

        it 'has no production' do
          expect(tech.production_at(1)).to be_zero
        end

        it 'has no mandatory consumption' do
          expect(tech.mandatory_consumption_at(1)).to eq(0)
        end

        it 'has conditional consumption of 5' do
          expect(tech.conditional_consumption_at(1)).to eq(5)
        end

        it 'stores nothing' do
          expect(tech.stored[1]).to be_zero
        end

        context 'assigned 5.0 conditional by the calculator' do
          before { tech.store(1, 5.0) }

          it 'stores 5.0' do
            expect(tech.stored[1]).to eq(5.0)
          end
        end

        context 'assigned 1.0 conditional by the calculator' do
          before { tech.store(1, 1.0) }

          it 'stores 1.0' do
            expect(tech.stored[1]).to eq(1.0)
          end
        end
      end # and use of 2.5

      context 'with required availability of 2.0' do
        let(:avail_profile) { [0.0, 2.0] * 4380 }
        let(:use_profile)   { [0.0] * 8760 }

        it 'has no production' do
          expect(tech.production_at(1)).to be_zero
        end

        it 'has mandatory consumption of 2.0' do
          expect(tech.mandatory_consumption_at(1)).to eq(2)
        end

        it 'has conditional consumption of 3.0' do
          expect(tech.conditional_consumption_at(1)).to eq(3)
        end

        it 'stores 2.0' do
          expect(tech.stored[1]).to eq(2)
        end

        context 'and use of 2.0' do
          let(:use_profile) { [0.0, 2.0] * 4380 }

          it 'has no production' do
            expect(tech.production_at(1)).to be_zero
          end

          it 'has mandatory consumption of 2.0' do
            expect(tech.mandatory_consumption_at(1)).to eq(2)
          end

          it 'has conditional consumption of 3.0' do
            expect(tech.conditional_consumption_at(1)).to eq(3)
          end

          it 'stores nothing' do
            expect(tech.stored[1]).to eq(2)
          end

          context 'storing 2.0' do
            before { tech.store(1, 2.0) }

            it 'stores 4.0' do
              # 2 according to the availability profile, and an extra 2 given
              # as conditional consumption.
              expect(tech.stored[1]).to eq(4)
            end
          end

          context 'storing 1.0' do
            before { tech.store(1, 1.0) }

            it 'stores 3.0' do
              expect(tech.stored[1]).to eq(3)
            end
          end
        end # and use of 2.0
      end # and required availability of 2.0
    end # with nothing stored

    context 'with 2.5 stored' do
      before { tech.stored[0] = 2.5 }

      context 'and no use' do
        let(:avail_profile) { [0.0] * 8760 }
        let(:use_profile)   { [0.0] * 8760 }

        it 'has production of 2.5' do
          expect(tech.production_at(1)).to eq(2.5)
        end

        it 'has mandatory consumption of 2.5' do
          expect(tech.mandatory_consumption_at(1)).to eq(2.5)
        end

        it 'has conditional consumption of 5.0' do
          expect(tech.conditional_consumption_at(1)).to eq(5)
        end

        it 'has 2.5 remaining storage' do
          expect(tech.stored[1]).to eq(2.5)
        end

        context 'with required availability of 2.0' do
          let(:avail_profile) { [0.0, 2.0] * 4380 }

          it 'has production of 2.5' do
            expect(tech.production_at(1)).to eq(2.5)
          end

          it 'has mandatory consumption of 2.5' do
            # 2.5 stored is more than the 2.0 required, therefore we don't need
            # to get anything extra.
            expect(tech.mandatory_consumption_at(1)).to eq(2.5)
          end

          it 'has conditional consumption of 5.0' do
            expect(tech.conditional_consumption_at(1)).to eq(5)
          end

          it 'has 2.5 remaining storage' do
            expect(tech.stored[1]).to eq(2.5)
          end
        end # and required availability of 2.0
      end # and no use

      context 'and a use of 1.5' do
        let(:avail_profile) { [0.0] * 8760 }
        let(:use_profile)   { [0.0, 1.5] * 4380 }

        it 'has production of 1.0' do
          expect(tech.production_at(1)).to eq(1)
        end

        it 'has mandatory consumption of 1.0' do
          expect(tech.mandatory_consumption_at(1)).to eq(1)
        end

        it 'has conditional consumption of 5.0' do
          expect(tech.conditional_consumption_at(1)).to eq(5)
        end

        it 'has 1.0 remaining storage' do
          expect(tech.stored[1]).to eq(1)
        end

        context 'with required availability of 2.0' do
          let(:avail_profile) { [0.0, 2.0] * 4380 }

          it 'has production of 1.0' do
            expect(tech.production_at(1)).to eq(1)
          end

          it 'has mandatory consumption of 2.0' do
            # 2.5 stored - 1.5 used   = 1.0 remaining stored
            # additional 1.0 required = 2.0 mandatory
            expect(tech.mandatory_consumption_at(1)).to eq(2)
          end

          it 'has conditional consumption of 4.0' do
            expect(tech.conditional_consumption_at(1)).to eq(4)
          end

          it 'has 2.0 remaining storage' do
            expect(tech.stored[1]).to eq(2)
          end
        end # and required availability of 2.0

        context 'and a capacity of 0.5' do
          let(:capacity) { 0.5 }

          it 'has production of 1.0' do
            expect(tech.production_at(1)).to eq(1)
          end

          it 'has mandatory consumption of 1.0' do
            expect(tech.mandatory_consumption_at(1)).to eq(1)
          end

          it 'has conditional consumption of 0.5' do
            expect(tech.conditional_consumption_at(1)).to eq(0.5)
          end
        end # and a capacity of 0.5

        context 'and a capacity of 2.0' do
          let(:capacity) { 2.0 }

          it 'has production of 1.0' do
            expect(tech.production_at(1)).to eq(1)
          end

          it 'has mandatory consumption of 1.0' do
            expect(tech.mandatory_consumption_at(1)).to eq(1)
          end

          it 'has conditional consumption of 2.0' do
            expect(tech.conditional_consumption_at(1)).to eq(2)
          end
        end # and a capacity of 2.0
      end # and a required load of 1.5

      context 'and a use of 2.5' do
        let(:avail_profile) { [0.0] * 8760 }
        let(:use_profile)   { [0.0, 2.5] * 4380 }

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

      context 'and a use of 5.0' do
        let(:avail_profile) { [0.0] * 8760 }
        let(:use_profile)   { [0.0, 5.0] * 4380 }

        it 'has no production' do
          expect(tech.production_at(1)).to be_zero
        end

        it 'has mandatory consumption of zero' do
          expect(tech.mandatory_consumption_at(1)).to be_zero
        end

        it 'has conditional consumption of 5.0' do
          expect(tech.conditional_consumption_at(1)).to eq(5)
        end

        it 'has no remaining storage' do
          expect(tech.stored[1]).to be_zero
        end

        context 'and required availability of 2.0' do
          let(:avail_profile) { [0.0, 2.0] * 4380 }

          context 'and a capacity of 2.0' do
            let(:capacity) { 2.0 }

            it 'has no production' do
              expect(tech.production_at(1)).to be_zero
            end

            it 'has mandatory consumption of 2.0' do
              expect(tech.mandatory_consumption_at(1)).to eq(2)
            end

            it 'has no conditional consumption' do
              expect(tech.conditional_consumption_at(1)).to be_zero
            end
          end # and a capacity of 2.0

          context 'and a capacity of 50' do
            let(:capacity) { 50.0 }

            it 'has no production' do
              expect(tech.production_at(1)).to be_zero
            end

            it 'has mandatory consumption of 2' do
              expect(tech.mandatory_consumption_at(1)).to eq(2)
            end

            it 'has conditional consumption of 48' do
              expect(tech.conditional_consumption_at(1)).to eq(48)
            end
          end # and a capacity of 50
        end # and required availability of 2.0
      end # and a use of 5.0
    end # with 2.5 stored
  end # with a storage volume of 50

  describe 'when disabled' do
    let(:avail_profile) { [0.0] * 8760 }
    let(:use_profile)   { [0.0] * 8760 }

    let(:tech) do
      network_technology(
        build(
          :installed_heat_pump, profile: avail_profile,
          capacity: 5.0, volume: 50.0
        ), 8760,
        buffering_space_heating: false,
        additional_profile: use_profile
      )
    end

    it 'remains a LegacyBuffer' do
      expect(tech).to be_a(Network::Technologies::LegacyBuffer)
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

    context 'and an availability profile value of 1.0' do
      let(:avail_profile) { [0.0, 1.0] * 4380 }

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

    context 'and availability and use values of 1.0' do
      let(:avail_profile) { [0.0, 1.0, 0.0] * 2920 }
      let(:use_profile) { [0.0, 0.0, 1.0] * 2920 }

      it 'has no production' do
        expect(tech.production_at(1)).to be_zero
      end

      it 'has mandatory consumption of 1.0' do
        expect(tech.mandatory_consumption_at(1)).to eq(1.0)
        expect(tech.mandatory_consumption_at(2)).to eq(0.0)
      end

      it 'has no conditional consumption' do
        expect(tech.conditional_consumption_at(1)).to be_zero
      end
    end # and a profile value of 1.0

    context 'with a value of -1' do
      let(:avail_profile) { [0.0, -1.0] * 4380 }

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
