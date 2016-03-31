require 'rails_helper'

module Network::Chain
  RSpec.describe Source do
    context 'with demand of 2.0' do
      context 'and no capacity set' do
        let(:source) { Source.new(profile: [2.0])}

        it 'has a load of 2.0' do
          expect(source.call(0)).to eql(2.0)
        end
      end

      context 'and a capacity of 1.0' do
        let(:source) { Source.new(profile: [2.0], capacity: 1.0)}

        it 'has a load of 1.0' do
          expect(source.call(0)).to eql(1.0)
        end
      end
    end

    context 'with a demand of -2.0' do
      context 'and no capacity set' do
        let(:source) { Source.new(profile: [-2.0]) }

        it 'has a load of -2.0' do
          expect(source.call(0)).to eq(-2.0)
        end
      end

      context 'and a capacity of 1.0' do
        let(:source) { Source.new(profile: [-2.0], capacity: 1.0) }

        it 'has a load of -1.0' do
          expect(source.call(0)).to eq(-1.0)
        end
      end
    end # with a demand of 2.0

    context 'with no capacity and a curve: [1.0, 2.0, 3.0]' do
      let(:source) { Source.new(profile: [1.0, 2.0, 3.0]) }

      it 'has a load of 1.0 in frame 0' do
        expect(source.call(0)).to eql(1.0)
      end

      it 'has a load of 2.0 in frame 1' do
        expect(source.call(1)).to eql(2.0)
      end

      it 'has a load of 3.0 in frame 2' do
        expect(source.call(2)).to eql(3.0)
      end

      it 'has no load in frame 3' do
        expect(source.call(3)).to be_zero
      end
    end

    context 'given a depleting curve with values [2.0, 1.0]' do
      let(:profile) { Network::DepletingCurve.new([2.0, 1.0]) }

      context 'and no capacity' do
        let(:source) { Source.new(profile: profile) }

        context 'in frame 0' do
          it 'has a load of 2.0' do
            expect(source.call(0)).to eq(2.0)
          end

          it 'still has a load of 2.0 when called again' do
            source.call(0)
            expect(source.call(0)).to eq(2.0)
          end

          it 'depletes 2.0 from the profile' do
            expect { source.call(0) }.
              to change { profile.at(0) }.from(2.0).to(0.0)
          end

          it 'does not deplete more than 2.0 when called again' do
            source.call(0)

            expect { source.call(0) }
              .to_not change { profile.at(0) }.from(0.0)
          end
        end

        context 'in frame 1' do
          it 'has a load of 1.0' do
            expect(source.call(1)).to eq(1.0)
          end

          it 'depletes 1.0 from the profile' do
            expect { source.call(1) }.
              to change { profile.at(1) }.from(1.0).to(0.0)
          end

          it 'does not deplete more than 1.0 when called again' do
            source.call(1)

            expect { source.call(1) }.
              to_not change { profile.at(1) }.from(0.0)
          end
        end
      end # and no capacity

      context 'and capacity of 1.5' do
        let(:source) { Source.new(profile: profile, capacity: 1.5) }

        context 'in frame 0' do
          it 'has a load of 1.5' do
            expect(source.call(0)).to eq(1.5)
          end

          it 'still has a load of 1.5 when called again' do
            source.call(0)
            expect(source.call(0)).to eq(1.5)
          end

          it 'depletes 1.5 from the profile' do
            expect { source.call(0) }.
              to change { profile.at(0) }.from(2.0).to(0.5)
          end

          it 'does not deplete more than 1.5 when called again' do
            source.call(0)

            expect { source.call(0) }
              .to_not change { profile.at(0) }.from(0.5)
          end
        end

        context 'in frame 1' do
          it 'has a load of 1.0' do
            expect(source.call(1)).to eq(1.0)
          end

          it 'depletes 1.0 from the profile' do
            expect { source.call(1) }.
              to change { profile.at(1) }.from(1.0).to(0.0)
          end

          it 'does not deplete more than 1.0 when called again' do
            source.call(1)

            expect { source.call(1) }.
              to_not change { profile.at(1) }.from(0.0)
          end
        end
      end # and capacity of 1.5
    end # given a depleting curve with values [2.0, 1.0]
  end # Source
end
