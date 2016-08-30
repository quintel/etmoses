require 'rails_helper'

module Network::Heat
  RSpec.describe ProductionPark do
    let(:installed_di) do
      double.tap { |d| allow(d).to receive(:dispatchable).and_return(true) }
    end

    let(:installed_mr) do
      double.tap { |d| allow(d).to receive(:dispatchable).and_return(false) }
    end

    let(:volume)           { 2.0 }
    let(:amplified_volume) { volume }

    let(:park) do
      ProductionPark.new(
        must_run:         must_run,
        dispatchable:     dispatchable,
        volume:           volume,
        amplified_volume: amplified_volume
      )
    end

    # --------------------------------------------------------------------------

    describe 'with a volume of 2.0 and amplified volume of 1.8' do
      let(:volume)           { 2.0 }
      let(:amplified_volume) { 1.8 }
      let(:dispatchable)     { [] }
      let(:must_run)         { [] }

      it 'raises an error' do
        expect { park }.to raise_error(
          'Amplified volume (1.8) must be equal to or greater ' \
          'than the volume (2.0)'
        )
      end
    end

    describe 'with a must run (2.0) and a dispatchable (1.0)' do
      let(:must_run)         { [Producer.new(installed_mr, [2.0])] }
      let(:dispatchable)     { [Producer.new(installed_di, [1.0])] }

      it 'has 3.0 available production' do
        expect(park.available_production_at(0)).to eq(3.0)
      end

      context 'assigning 1.0 consumption' do
        let!(:consumed) { park.consume(0, 1.0) }

        it 'returns 1.0' do
          expect(consumed).to eq(1.0)
        end

        it 'takes 1.0 from the must run' do
          expect(must_run.first.available_production_at(0)).to eq(1.0)
        end

        it 'takes nothing from the dispatchables' do
          expect(dispatchable.first.available_production_at(0)).to eq(1.0)
        end

        it 'then has 2.0 available production' do
          expect(park.available_production_at(0)).to eq(2.0)
        end

        context 'then assigning 1.5 more' do
          let!(:consumed_again) { park.consume(0, 1.5) }

          it 'returns 1.5' do
            expect(consumed_again).to eq(1.5)
          end

          it 'takes 1.0 from the must run' do
            expect(must_run.first.available_production_at(0)).to be_zero
          end

          it 'takes 0.5 from the dispatchables' do
            expect(dispatchable.first.available_production_at(0)).to eq(0.5)
          end

          it 'then has 0.5 available production' do
            expect(park.available_production_at(0)).to eq(0.5)
          end
        end # then assigning 1.5 more

        context 'storing excess' do
          let(:stored) { park.reserve_excess_at!(0) }

          it 'returns 2.0' do
            expect(stored).to eq(2.0)
          end

          it 'reduces available must-run energy to zero' do
            expect { stored }.
              to change { dispatchable.first.available_production_at(0) }.
              from(1.0).to(0.0)
          end

          it 'reduces available dispatchable energy to zero' do
            expect { stored }.
              to change { dispatchable.first.available_production_at(0) }.
              from(1.0).to(0.0)
          end

          it 'adds the energy to the reserve' do
            stored
            expect(park.reserved_at(0)).to eq(2.0)
          end
        end # storing excess
      end # assigning 1.0 consumption

      context 'assigning 4.0 consumption' do
        let!(:consumed) { park.consume(0, 3.0) }

        it 'returns 3.0' do
          expect(consumed).to eq(3.0)
        end

        it 'takes 2.0 from the must run' do
          expect(must_run.first.available_production_at(0)).to be_zero
        end

        it 'takes 1.0 from the dispatchables' do
          expect(dispatchable.first.available_production_at(0)).to be_zero
        end

        it 'then has no available production' do
          expect(park.available_production_at(0)).to be_zero
        end
      end # assigning 4.0 consumption
    end # with a must run (2.0) and a dispatchable (1.0)

    describe 'with a volume of 2.0' do
      let(:dispatchable) { [] }
      let(:must_run)     { [] }
      let(:volume)       { 2.0 }

      context 'storing excess from a 1.0 must run' do
        let(:must_run) { [Producer.new(installed_mr, [1.0])] }
        let(:reserve)  { park.reserve_excess_at!(0) }

        it 'returns 1.0' do
          expect(reserve).to eq(1.0)
        end

        it 'stores 1.0 energy' do
          expect { reserve }.to change { park.reserved_at(0) }.from(0.0).to(1.0)
        end

        it 'takes 1.0 from the must-run' do
          expect { reserve }
            .to change { must_run.first.available_production_at(0) }
            .from(1.0).to(0.0)
        end
      end # storing excess from a 1.0 must run

      context 'storing excess from a 3.0 must run' do
        let(:must_run) { [Producer.new(installed_mr, [3.0])] }
        let(:reserve)  { park.reserve_excess_at!(0) }

        it 'returns 2.0' do
          expect(reserve).to eq(2.0)
        end

        it 'stores 2.0 energy' do
          expect { reserve }.to change { park.reserved_at(0) }.from(0.0).to(2.0)
        end

        it 'takes 2.0 from the must-run' do
          expect { reserve }
            .to change { must_run.first.available_production_at(0) }
            .from(3.0).to(1.0)
        end
      end # storing excess from a 3.0 must run

      context 'storing excess from a 1.0 dispatchable' do
        let(:dispatchable) { [Producer.new(installed_di, [1.0])] }
        let(:reserve)      { park.reserve_excess_at!(0) }

        it 'returns 1.0' do
          expect(reserve).to eq(1.0)
        end

        it 'stores 1.0 energy' do
          expect { reserve }.to change { park.reserved_at(0) }.from(0.0).to(1.0)
        end

        it 'takes 1.0 from the dispatchable' do
          expect { reserve }.
            to change { dispatchable.first.available_production_at(0) }.
            from(1.0).to(0.0)
        end
      end # storing excess from a 1.0 dispatchable

      context 'storing excess from a 3.0 dispatchable' do
        let(:dispatchable) { [Producer.new(installed_di, [3.0])] }
        let(:reserve)      { park.reserve_excess_at!(0) }

        it 'returns 2.0' do
          expect(reserve).to eq(2.0)
        end

        it 'stores 2.0 energy' do
          expect { reserve }.to change { park.reserved_at(0) }.from(0.0).to(2.0)
        end

        it 'takes 2.0 from the dispatchable' do
          expect { reserve }.
            to change { dispatchable.first.available_production_at(0) }.
            from(3.0).to(1.0)
        end
      end # storing excess from a 3.0 dispatchable

      context 'storing excess from a 1.0 must run and 2.0 dispatchable' do
        let(:dispatchable) { [Producer.new(installed_di, [2.0])] }
        let(:must_run)     { [Producer.new(installed_mr, [1.0])] }
        let(:reserve)      { park.reserve_excess_at!(0) }

        it 'returns 2.0' do
          expect(reserve).to eq(2.0)
        end

        it 'stores 2.0 energy' do
          expect { reserve }.to change { park.reserved_at(0) }.from(0.0).to(2.0)
        end

        it 'takes 1.0 from the must-run' do
          expect { reserve }.
            to change { must_run.first.available_production_at(0) }.
            from(1.0).to(0.0)
        end

        it 'takes 1.0 from the dispatchable' do
          expect { reserve }.
            to change { dispatchable.first.available_production_at(0) }.
            from(2.0).to(1.0)
        end
      end # storing excess from a 1.0 must run and 2.0 dispatchable
    end # with a volume of 2.0

    context 'with a volume of 2.0 and amplified volume of 3.5' do
      let(:dispatchable)     { [] }
      let(:must_run)         { [] }
      let(:volume)           { 2.0 }
      let(:amplified_volume) { 3.5 }

      context 'storing excess from a 1.0 must run' do
        let(:must_run) { [Producer.new(installed_mr, [1.0])] }
        let(:reserve)  { park.reserve_excess_at!(0) }

        it 'returns 1.0' do
          expect(reserve).to eq(1.0)
        end

        it 'stores 1.0 energy' do
          expect { reserve }.to change { park.reserved_at(0) }.from(0.0).to(1.0)
        end

        it 'takes 1.0 from the must-run' do
          expect { reserve }.
            to change { must_run.first.available_production_at(0) }.
            from(1.0).to(0.0)
        end
      end # storing excess from a 1.0 must run

      context 'storing excess from a 3.0 must run' do
        let(:must_run) { [Producer.new(installed_mr, [3.0])] }
        let(:reserve)  { park.reserve_excess_at!(0) }

        it 'returns 3.0' do
          expect(reserve).to eq(3.0)
        end

        it 'stores 3.0 energy' do
          expect { reserve }.to change { park.reserved_at(0) }.from(0.0).to(3.0)
        end

        it 'takes 3.0 from the must-run' do
          expect { reserve }.
            to change { must_run.first.available_production_at(0) }.
            from(3.0).to(0.0)
        end
      end # storing excess from a 3.0 must run

      context 'storing excess from a 1.0 must run in two frames' do
        let(:must_run) { [Producer.new(installed_mr, [1.0, 1.0])] }
        let!(:reserve_zero)  { park.reserve_excess_at!(0) }
        let!(:reserve_one)  { park.reserve_excess_at!(1) }

        it 'stores 1.0 in frame 0' do
          expect(park.reserved_at(0)).to eq(1.0)
        end

        it 'has 2.0 available in frame 1' do
          expect(park.available_production_at(1)).to eq(2.0)
        end

        it 'stores 2.0 in frame 1' do
          expect(park.reserved_at(1)).to eq(2.0)
        end
      end # storing excess from a 1.0 must run in two frames

      context 'storing excess from a 1.0 dispatchable' do
        let(:dispatchable) { [Producer.new(installed_di, [1.0])] }
        let(:reserve)      { park.reserve_excess_at!(0) }

        it 'returns 1.0' do
          expect(reserve).to eq(1.0)
        end

        it 'stores 1.0 energy' do
          expect { reserve }.to change { park.reserved_at(0) }.from(0.0).to(1.0)
        end

        it 'takes 1.0 from the dispatchable' do
          expect { reserve }.
            to change { dispatchable.first.available_production_at(0) }.
            from(1.0).to(0.0)
        end
      end # storing excess from a 1.0 dispatchable

      context 'storing excess from a 3.0 dispatchable' do
        let(:dispatchable) { [Producer.new(installed_di, [3.0])] }
        let(:reserve)      { park.reserve_excess_at!(0) }

        it 'returns 2.0' do
          expect(reserve).to eq(2.0)
        end

        it 'stores 2.0 energy' do
          expect { reserve }.to change { park.reserved_at(0) }.from(0.0).to(2.0)
        end

        it 'takes 2.0 from the dispatchable' do
          expect { reserve }.
            to change { dispatchable.first.available_production_at(0) }.
            from(3.0).to(1.0)
        end
      end # storing excess from a 3.0 dispatchable

      context 'storing excess from a 1.0 must run and 2.0 dispatchable' do
        let(:dispatchable) { [Producer.new(installed_di, [2.0])] }
        let(:must_run)     { [Producer.new(installed_mr, [1.0])] }
        let(:reserve)      { park.reserve_excess_at!(0) }

        it 'returns 2.0' do
          expect(reserve).to eq(2.0)
        end

        it 'stores 2.0 energy' do
          expect { reserve }.to change { park.reserved_at(0) }.from(0.0).to(2.0)
        end

        it 'takes 1.0 from the must-run' do
          expect { reserve }.
            to change { must_run.first.available_production_at(0) }.
            from(1.0).to(0.0)
        end

        it 'takes 1.0 from the dispatchable' do
          expect { reserve }.
            to change { dispatchable.first.available_production_at(0) }.
            from(2.0).to(1.0)
        end
      end # storing excess from a 1.0 must run and 2.0 dispatchable

      context 'storing excess from a 3.0 must run and 2.0 dispatchable' do
        let(:dispatchable) { [Producer.new(installed_di, [2.0])] }
        let(:must_run)     { [Producer.new(installed_mr, [3.0])] }
        let(:reserve)      { park.reserve_excess_at!(0) }

        it 'returns 3.0' do
          expect(reserve).to eq(3.0)
        end

        it 'stores 3.0 energy' do
          expect { reserve }.to change { park.reserved_at(0) }.from(0.0).to(3.0)
        end

        it 'takes 3.0 from the must-run' do
          expect { reserve }.
            to change { must_run.first.available_production_at(0) }.
            from(3.0).to(0.0)
        end

        it 'takes nothing from the dispatchable' do
          expect { reserve }.
            not_to change { dispatchable.first.available_production_at(0) }.
            from(2.0)
        end
      end # storing excess from a 3.0 must run and 2.0 dispatchable
    end # with a volume of 2.0 and amplified volume of 3.5
  end # ProductionPark
end # Network::Heat
