require 'rails_helper'

RSpec.describe Network::Technologies::DeferrableConsumer do
  let(:capacity) { 5.0 }

  let(:tech) do
    network_technology(build(
      :installed_deferred, profile: profile, capacity: capacity
    ), 8760, curve_type: :flex)
  end

  context 'with no stored amount' do
    let(:profile) { [0.0] * 8760 }

    it 'defaults to having no deferred loads' do
      expect(tech.conditional_consumption_at(0, nil)).to be_zero
    end
  end

  context 'wanting 2.0' do
    let(:profile) { [2.0] * 8760 }

    it 'has no mandatory consumption' do
      expect(tech.mandatory_consumption_at(0)).to be_zero
    end

    it 'has conditional consumption of 5' do
      expect(tech.conditional_consumption_at(0, nil)).to eq(2.0)
    end

    context 'receiving 2.0' do
      before { tech.store(0, 2.0) }

      it 'does not defer any load' do
        expect(tech.mandatory_consumption_at(1)).to be_zero
        expect(tech.conditional_consumption_at(1, nil)).to eq(2.0)
      end
    end # receiving 2.0

    context 'receiving 1.0' do
      before { tech.store(0, 1.0) }

      it 'defers 1.0' do
        expect(tech.mandatory_consumption_at(1)).to be_zero
        expect(tech.conditional_consumption_at(1, nil)).to eq(3.0)
      end

      it 'has 1.0 deferred becoming mandatory in frame 12' do
        expect(tech.mandatory_consumption_at(12)).to eq(1.0)
        expect(tech.conditional_consumption_at(12, nil)).to eq(2.0)
      end
    end # receiving nothing

    context 'receiving nothing' do
      before { tech.store(0, 0.0) }

      it 'defers 2.0' do
        expect(tech.mandatory_consumption_at(1)).to be_zero
        expect(tech.conditional_consumption_at(1, nil)).to eq(4.0)
      end

      it 'has 2.0 deferred becoming mandatory in frame 12' do
        expect(tech.mandatory_consumption_at(12)).to eq(2.0)
        expect(tech.conditional_consumption_at(12, nil)).to eq(2.0)
      end

      context 'receiving 1.0 in the next frame' do
        before { tech.store(1, 1.0) }

        it 'defers more' do
          expect(tech.mandatory_consumption_at(2)).to be_zero
          # 1.0 - 2.0 deferred in f:0, 1.0 given in this step
          # 2.0 - 2.0 deferred in f:1
          # 2.0 - 2.0 wanted in f:2
          # -----
          # = 5.0
          expect(tech.conditional_consumption_at(2, nil)).to eq(5.0)
        end

        it 'has 1.0 deferred becoming mandatory in frame 12' do
          expect(tech.mandatory_consumption_at(12)).to eq(1.0)
        end

        it 'has 2.0 deferred becoming mandatory in frame 13' do
          expect(tech.mandatory_consumption_at(13)).to eq(2.0)
        end
      end

      context 'receiving 3.0 in the next frame' do
        before { tech.store(1, 3.0) }

        it 'defers nothing more' do
          expect(tech.mandatory_consumption_at(2)).to be_zero
          expect(tech.conditional_consumption_at(2, nil)).to eq(3.0)
        end

        it 'has no deferred becoming mandatory in frame 12' do
          expect(tech.mandatory_consumption_at(12)).to be_zero
        end

        it 'has 1.0 deferred becoming mandatory in frame 13' do
          expect(tech.mandatory_consumption_at(13)).to eq(1.0)
        end
      end
    end # receiving nothing

    context 'receiving 1.0 in the second-to-last frame' do
      before { tech.store(8758, 1.0) }

      it 'has 3.0 mandatory in the last frame' do
        expect(tech.mandatory_consumption_at(8759)).to eq(3.0)
      end

      it 'has no conditional in the last frame' do
        expect(tech.conditional_consumption_at(8759, nil)).to be_zero
      end
    end # receiving 1.0 in the second-to-last frame
  end # wanting 2.0
end
