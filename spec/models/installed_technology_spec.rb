require 'rails_helper'

RSpec.describe InstalledTechnology do
  describe '#exists?' do
    it 'returns false when :type is set to a non-existent technology' do
      expect(InstalledTechnology.new(type: 'nope')).to_not be_exists
    end

    it 'returns true when :type is not set' do
      expect(InstalledTechnology.new).to be_exists
    end

    it 'returns true when :type is set to a real technology' do
      create(:technology, key: 'tech_one')
      expect(InstalledTechnology.new(type: 'tech_one')).to be_exists
    end
  end

  describe '#technology' do
    it 'raises ActiveRecord::RecordNotFound when no such tech exists' do
      expect { InstalledTechnology.new(type: 'nope').technology }.
        to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'returns a generic tech when :type is not set' do
      lib = InstalledTechnology.new.technology

      expect(lib).to be_a(Technology)
      expect(lib.key).to eq('generic')
    end

    it 'returns the correct tech when :type is set' do
      create(:technology, key: 'tech_one')
      lib = InstalledTechnology.new(type: 'tech_one').technology

      expect(lib).to be_a(Technology)
      expect(lib.key).to eq('tech_one')
    end
  end # technology

  describe '#profile=' do
    context 'with nil' do
      let(:tech) { InstalledTechnology.new(profile: nil) }

      it 'sets the profile to be blank' do
        expect(tech.profile).to be_nil
      end
    end

    context 'with load profile key' do
      let(:tech) { InstalledTechnology.new(profile: 'my_little_profile') }

      it 'sets an inline array profile' do
        expect(tech.profile).to eq('my_little_profile')
      end
    end

    context 'with an array-like string' do
      let(:tech) { InstalledTechnology.new(profile: '[1, 2, 3]') }

      it 'sets an inline array profile' do
        expect(tech.profile).to eq([1, 2, 3])
      end
    end

    context 'with an array' do
      let(:tech) { InstalledTechnology.new(profile: [1, 2, 3]) }

      it 'sets an inline array profile' do
        expect(tech.profile).to eq([1, 2, 3])
      end
    end
  end # profile=

  describe '#profile_curve' do
    let(:load_profile) { create(:load_profile_with_curve) }

    %w(capacity load).each do |attribute|
      context "with #{ attribute }" do
        let(:tech) { InstalledTechnology.new(attribute => 2.0) }

        context 'and an inline curve' do
          before { tech.profile = [2.0] }

          it 'scales without units' do
            expect(tech.profile_curve[:default].at(0)).to eq(4.0)
          end

          it 'scales with units' do
            tech.units = 2.0
            expect(tech.profile_curve[:default].at(0)).to eq(8.0)
          end
        end # and an inline curve

        context 'and a LoadProfile-based curve' do
          before do
            expect(LoadProfile).to receive(:by_key).and_return(load_profile)
          end

          it 'scales without units' do
            expect(tech.profile_curve['flex'].at(0)).to eq(1.0)
          end

          it 'scales with units' do
            tech.units = 2.0
            expect(tech.profile_curve['flex'].at(0)).to eq(2.0)
          end
        end
      end # with {attribute}
    end # [capacity load] each

    context 'with demand' do
      let(:tech) { InstalledTechnology.new(demand: 100.0) }

      context 'and an inline profile' do
        before { tech.profile = [2.0] }

        it 'scales without units' do
          expect(tech.profile_curve[:default].at(0)).to eq(200.0)
        end

        it 'scales with units' do
          tech.units = 2.0
          expect(tech.profile_curve[:default].at(0)).to eq(400.0)
        end
      end

      context 'and a LoadProfile-based curve' do
        before do
          expect(LoadProfile).to receive(:by_key).and_return(load_profile)
        end

        it 'scales without units' do
          expect(tech.profile_curve['flex'].at(0)).to be_within(1e-5).of(50.0 / 8760)
        end

        it 'scales with units' do
          tech.units = 2.0
          expect(tech.profile_curve['flex'].at(0)).to be_within(1e-5).of(100.0 / 8760)
        end
      end
    end # with demand

    context 'with neither capacity nor demand' do
      let(:tech) { InstalledTechnology.new }

      context 'and an inline profile' do
        before { tech.profile = [2.0] }

        it 'scales without units' do
          expect(tech.profile_curve[:default].at(0)).to eq(2.0)
        end

        it 'scales with units' do
          tech.units = 2.0
          expect(tech.profile_curve[:default].at(0)).to eq(4.0)
        end
      end

      context 'and a LoadProfile-based curve' do
        before do
          expect(LoadProfile).to receive(:by_key).and_return(load_profile)
        end

        it 'scales without units' do
          expect(tech.profile_curve['flex'].at(0)).to eq(2.0)
        end

        it 'scales with units' do
          tech.units = 2.0
          expect(tech.profile_curve['flex'].at(0)).to eq(4.0)
        end
      end
    end # with neither capacity nor demand

    context 'with volume' do
      let(:tech) { InstalledTechnology.new(volume: 100.0) }

      before do
        expect(LoadProfile).to receive(:by_key).and_return(load_profile)
      end

      it 'scales without units' do
        expect(tech.profile_curve['flex'].at(0)).to eq(200.0)
      end

      it 'scales with units' do
        tech.units = 2.0
        expect(tech.profile_curve['flex'].at(0)).to eq(400.0)
      end
    end # with volume

    context 'with volume and capacity' do
      let(:tech) { InstalledTechnology.new(volume: 100.0, capacity: 0.2) }

      before do
        expect(LoadProfile).to receive(:by_key).and_return(load_profile)
      end

      it 'scales without units' do
        expect(tech.profile_curve['flex'].at(0)).to eq(200.0)
      end

      it 'scales with units' do
        tech.units = 2.0
        expect(tech.profile_curve['flex'].at(0)).to eq(400.0)
      end
    end # with volume and capacity
  end # profile_curve
end # InstalledTechnology
