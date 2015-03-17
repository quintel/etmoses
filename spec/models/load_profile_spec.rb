require 'rails_helper'

RSpec.describe LoadProfile, type: :model do
  describe 'when saved' do
    let(:load_profile) { create(:load_profile) }

    let(:original) do
      Merit::Curve.load_file("#{Rails.root}/spec/fixtures/data/curves/one.csv")
    end

    context 'the original file' do
      let(:curve) do
        Merit::Curve.load_file(load_profile.curve.path(:original))
      end

      it 'is saved' do
        expect(File.file?(load_profile.curve.path)).to be
      end

      it 'is identical to the uploaded file' do
        expect(curve.length).to eq(original.length)
        expect(curve.to_a).to   eq(original.to_a)
      end
    end

    context 'the capacity-scaled profile' do
      let(:curve) do
        Merit::Curve.load_file(load_profile.curve.path(:capacity_scaled))
      end

      it 'is saved' do
        expect(File.file?(load_profile.curve.path(:capacity_scaled))).to be
      end

      it 'has the same number of points as the original' do
        expect(curve.length).to eq(original.length)
      end

      it 'scaled values so that the maximum is 1.0' do
        expect(curve.max).to eq(1.0)
      end

      it 'scaled values according to the maximum' do
        # Maximum value in one.csv is 4, therefore all values are divided by 4.
        expect(curve.get(0)).to eq(original.get(0) / 4)
      end
    end

    context 'the demand-scaled profile' do
      let(:curve) do
        Merit::Curve.load_file(load_profile.curve.path(:demand_scaled))
      end

      it 'is saved' do
        expect(File.file?(load_profile.curve.path(:demand_scaled))).to be
      end

      it 'has the same number of points as the original' do
        expect(curve.length).to eq(original.length)
      end

      it 'scaled values so that the sum of all values is 1.0' do
        expect(curve.reduce(:+)).to be_within(1e-8).of(1.0)
      end
    end
  end
end # LoadProfile
