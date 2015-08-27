require 'rails_helper'

RSpec.describe CurveCollection do
  context 'given two components containing [1, 3, 2, 2], and [3, 9, 6, 6]' do
    let(:curve_one) { Network::Curve.new([1.0, 3.0, 2.0, 2.0]) }
    let(:curve_two) { Network::Curve.new([3.0, 9.0, 6.0, 6.0]) }

    let(:component_one) do
      component = FactoryGirl.build(
        :load_profile_component,
        id: 1, curve_type: 'flex', curve: nil, curve_updated_at: Time.now
      )

      allow(component).to receive(:network_curve).and_return(curve_one)

      component
    end

    let(:component_two) do
      component = FactoryGirl.build(
        :load_profile_component,
        id: 2, curve_type: 'inflex', curve: nil, curve_updated_at: Time.now
      )

      allow(component).to receive(:network_curve).and_return(curve_two)

      component
    end

    subject do
      CurveCollection.new([component_one, component_two])
    end

    describe '#each_curve' do
      it 'yields each curve type' do
        expect(subject.each_curve.map(&:first)).to eql(%w(flex inflex))
      end

      it 'yields each scaled curve' do
        expect(subject.each_curve.map { |v| v[1].to_a }).to eql([
          curve_one.to_a, curve_two.to_a
        ])
      end

      it 'yields the ratio of each curve' do
        expect(subject.each_curve.map(&:last)).to eql([0.25, 0.75])
      end

      it 'yields the curves in curve_type alphanumeric order' do
        collection = CurveCollection.new([component_two, component_one])
        expect(collection.each_curve.map(&:first)).to eql(%w(flex inflex))
      end
    end # #each_curve
  end
end
