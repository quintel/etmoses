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

    context "with capacity" do
      let(:tech) { InstalledTechnology.new(capacity: 2.0) }

      context 'and an inline curve' do
        before { tech.profile = [2.0] }

        it 'scales without units' do
          expect(tech.profile_curve.curves[:default].at(0)).to eq(4.0)
        end

        it 'scales with units' do
          tech.units = 2.0
          expect(tech.profile_curve.curves[:default].at(0)).to eq(8.0)
        end
      end # and an inline curve

      context 'and a LoadProfile-based curve' do
        before do
          tech.profile = load_profile.id
        end

        it 'scales without units' do
          expect(tech.profile_curve.curves['flex'].at(0)).to eq(1.0)
        end

        it 'scales with units' do
          tech.units = 2.0
          expect(tech.profile_curve.curves['flex'].at(0)).to eq(2.0)
        end
      end
    end # with capacity

    context 'with demand' do
      let(:tech) { InstalledTechnology.new(demand: 8760.0) }

      context 'and an inline profile' do
        before { tech.profile = [1 / 8760.0] * 8760 }

        it 'scales without units' do
          expect(tech.profile_curve.curves[:default].at(0)).to eq(1.0)
        end

        it 'scales with units' do
          tech.units = 2.0
          expect(tech.profile_curve.curves[:default].at(0)).to eq(2.0)
        end

        context 'with a curve containing 35,040 frames' do
          # before { tech.profile = (tech.profile * 4) } #[2.0] * 35_040 }
          before { tech.profile = [1.0 / 35_040] * 35_040 }

          it 'converts kWh to the respective kW load' do
            expect(tech.profile_curve.curves[:default].at(0)).to eq(1.0)
          end

          it 'scales with units' do
            tech.units = 2.0
            expect(tech.profile_curve.curves[:default].at(0)).to eq(2.0)
          end
        end
      end

      context 'and a LoadProfile-based curve' do
        before      { tech.profile = load_profile.id }
        let(:curve) { tech.profile_curve.curves['flex'] }

        it 'scales without units' do
          expect(curve.at(0)).to be_within(1e-3).of(0.5)
          expect(curve.at(1)).to be_within(1e-3).of(1)
        end

        it 'scales with units' do
          tech.units = 2.0

          expect(curve.at(0)).to be_within(1e-3).of(1)
          expect(curve.at(1)).to be_within(1e-3).of(2)
        end
      end
    end # with demand

    context 'with neither capacity nor demand' do
      let(:tech) { InstalledTechnology.new }

      context 'and an inline profile' do
        before { tech.profile = [2.0] }

        it 'scales without units' do
          expect(tech.profile_curve.curves[:default].at(0)).to eq(2.0)
        end

        it 'scales with units' do
          tech.units = 2.0
          expect(tech.profile_curve.curves[:default].at(0)).to eq(4.0)
        end
      end

      context 'and a LoadProfile-based curve' do
        before { tech.profile = load_profile.id }

        it 'scales without units' do
          expect(tech.profile_curve.curves['flex'].at(0)).to eq(2.0)
        end

        it 'scales with units' do
          tech.units = 2.0
          expect(tech.profile_curve.curves['flex'].at(0)).to eq(4.0)
        end
      end
    end # with neither capacity nor demand

    context 'with volume' do
      let(:tech) { InstalledTechnology.new(volume: 100.0, capacity: nil) }
      before     { tech.profile = load_profile.id }

      it 'scales without units' do
        expect(tech.profile_curve.curves['flex'].at(0)).to eq(200.0)
      end

      it 'scales with units' do
        tech.units = 2.0
        expect(tech.profile_curve.curves['flex'].at(0)).to eq(400.0)
      end
    end # with volume

    pending 'with volume and capacity' do
      let(:tech) { InstalledTechnology.new(volume: 100.0, capacity: 0.2) }
      before     { tech.profile = load_profile.id }

      it 'scales without units' do
        expect(tech.profile_curve.curves['flex'].at(0)).to eq(200.0)
      end

      it 'scales with units' do
        tech.units = 2.0
        expect(tech.profile_curve.curves['flex'].at(0)).to eq(400.0)
      end
    end # with volume and capacity
  end # profile_curve

  describe 'performance_coefficient' do
    context 'when no value is set' do
      let(:tech) { InstalledTechnology.new }

      it 'defaults to 1.0' do
        expect(tech.performance_coefficient).to eq(1.0)
      end
    end # when no value is set

    context 'when set to nil' do
      let(:tech) { InstalledTechnology.new(performance_coefficient: nil) }

      it 'returns 1.0' do
        expect(tech.performance_coefficient).to eq(1.0)
      end
    end # when set to nil

    context 'when set to ""' do
      let(:tech) { InstalledTechnology.new(performance_coefficient: "") }

      it 'returns 1.0' do
        expect(tech.performance_coefficient).to eq(1.0)
      end
    end # when set to nil

    context 'when set to 4.0' do
      let(:tech) { InstalledTechnology.new(performance_coefficient: 4.0) }

      it 'returns 4.0' do
        expect(tech.performance_coefficient).to eq(4.0)
      end

      context 'when setting the electrical capacity to 1.0' do
        before { tech.carrier_capacity = 1.0 }

        it 'sets the capacity to 4.0' do
          expect(tech.capacity).to eq(4.0)
        end

        it 'sets capacity to 8.0 when changing the coefficient to 8.0' do
          tech.performance_coefficient = 8.0
          expect(tech.capacity).to eq(8.0)
        end
      end # when setting the electrical capacity

      context 'when setting the electrical capacity to nil' do
        before { tech.carrier_capacity = nil }

        it 'sets the capacity to nil' do
          expect(tech.capacity).to be_nil
        end

        it 'sets capacity to nil when changing the coefficient to 8.0' do
          tech.performance_coefficient = 8.0
          expect(tech.capacity).to be_nil
        end
      end # when setting the electrical capacity
    end # when set to 4.0
  end

  describe "editables" do
    it "does not include associates" do
      expect(InstalledTechnology::EDITABLES).to_not include(:associates)
    end
  end
end # InstalledTechnology
