require 'rails_helper'

RSpec.describe Network::Technologies::OptionalBuffer do
  context 'with a storage volume of 10' do
    let(:capacity) { Float::INFINITY }

    let(:tech) do
      network_technology(build(
        :installed_p2h, profile: profile, volume: 10.0, capacity: capacity
      ))
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

        it 'has conditional consumption equal to the volume' do
          expect(tech.conditional_consumption_at(1, nil)).to eq(10.0)
        end

        it 'stores nothing' do
          expect(tech.stored[1]).to be_zero
        end
      end

      # with nothing stored
      context 'and use of 2.5' do
        let(:profile) { [0.0, 2.5] * 4380 }

        it 'has no production' do
          expect(tech.production_at(1)).to be_zero
        end

        it 'has mandatory consumption of 0.0' do
          expect(tech.mandatory_consumption_at(1)).to be_zero
        end

        it 'has conditional consumption of 10' do
          expect(tech.conditional_consumption_at(1, nil)).to eq(10)
        end

        it 'stores nothing' do
          expect(tech.stored[1]).to be_zero
        end
      end
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

        it 'has conditional consumption of 10' do
          expect(tech.conditional_consumption_at(1, nil)).to eq(10)
        end

        it 'has 2.5 remaining storage' do
          expect(tech.stored[1]).to eq(2.5)
        end
      end # and no use

      # with 2.5 stored
      context 'and a use of 1.5' do
        let(:profile) { [0.0, 1.5] * 4380 }

        context 'assigned nothing' do
          it 'has no production of 1.0' do
            expect(tech.production_at(1)).to be_zero
          end

          it 'has no mandatory consumption' do
            expect(tech.mandatory_consumption_at(1)).to be_zero
          end

          it 'has conditional consumption of 10' do
            expect(tech.conditional_consumption_at(1, nil)).to eq(10)
          end

          it 'has 1.0 remaining storage' do
            expect(tech.stored[1]).to eq(1.0)
          end
        end

        # with 2.5 stored and a use of 1.5
        context 'and a capacity of 0.5' do
          let(:capacity) { 0.5 }

          it 'has no production' do
            expect(tech.production_at(1)).to be_zero
          end

          it 'has no mandatory consumption' do
            expect(tech.mandatory_consumption_at(1)).to be_zero
          end

          it 'has conditional consumption of 0.5' do
            expect(tech.conditional_consumption_at(1, nil)).to eq(0.5)
          end
        end # and a capacity of 0.5

        # with 2.5 stored and a use of 1.5
        context 'and a capacity of 2.0' do
          let(:capacity) { 2.0 }

          it 'has no production' do
            expect(tech.production_at(1)).to be_zero
          end

          it 'has no mandatory consumption' do
            expect(tech.mandatory_consumption_at(1)).to be_zero
          end

          it 'has conditional consumption of 2.0' do
            expect(tech.conditional_consumption_at(1, nil)).to eq(2.0)
          end
        end # and a capacity of 2.0
      end # and a required load of 1.5

      # with 2.5 stored
      context 'and a use of 2.5' do
        let(:profile) { [0.0, 2.5] * 4380 }

        it 'has production of 0.0' do
          expect(tech.production_at(1)).to be_zero
        end

        it 'has mandatory consumption of 0.0' do
          expect(tech.mandatory_consumption_at(1)).to be_zero
        end

        it 'has conditional consumption of 10' do
          expect(tech.conditional_consumption_at(1, nil)).to eq(10)
        end

        it 'has no remaining storage' do
          expect(tech.stored[1]).to be_zero
        end
      end # and a required load of 2.5

      # with 2.5 stored
      context 'and a use of 5.0' do
        let(:profile) { [0.0, 5.0] * 4380 }

        context 'assigned nothing' do
          it 'has production of 0.0' do
            expect(tech.production_at(1)).to be_zero
          end

          it 'has mandatory consumption of 0.0' do
            expect(tech.mandatory_consumption_at(1)).to be_zero
          end

          it 'has conditional consumption of 10' do
            expect(tech.conditional_consumption_at(1, nil)).to eq(10)
          end

          it 'has no remaining storage' do
            expect(tech.stored[1]).to be_zero
          end
        end

        # with 2.5 stored and a use of 5.0
        context 'and a capacity of 2.0' do
          let(:capacity) { 4.0 }

          it 'has production of 0.0' do
            expect(tech.production_at(1)).to be_zero
          end

          it 'has mandatory consumption of zero' do
            expect(tech.mandatory_consumption_at(1)).to be_zero
          end

          it 'has conditional consumption of 4.0' do
            expect(tech.conditional_consumption_at(1, nil)).to eq(4.0)
          end
        end # and a capacity of 2.0

        # with 2.5 stored and a use of 5.0
        context 'and a capacity of 50' do
          let(:capacity) { 50.0 }

          it 'has production of 0.0' do
            expect(tech.production_at(1)).to be_zero
          end

          it 'has mandatory consumption of zero' do
            expect(tech.mandatory_consumption_at(1)).to be_zero
          end

          it 'has conditional consumption of 10' do
            expect(tech.conditional_consumption_at(1, nil)).to eq(10)
          end
        end # and a capacity of 50
      end # and a use of 5.0
    end # with 2.5 stored
  end # with a storage volume of 10
end # OptionalBuffer
