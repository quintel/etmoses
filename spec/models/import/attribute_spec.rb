require 'rails_helper'

RSpec.describe Import::Attribute do
  context 'called with data from ETEngine' do
    let(:attribute) { Import::Attribute.new('attr') }
    let(:data) { { 'attr' => { 'present' => 2.5, 'future' => 5.0 } } }

    it 'can retrieve the future value of an attribute' do
      expect(attribute.future(data, 'attr')).to eq(5.0)
    end

    it 'can retrieve the present value of an attribute' do
      expect(attribute.present(data, 'attr')).to eq(2.5)
    end
  end # called with data from ETEngine

  context 'given no extractor block' do
    let(:attribute) { Import::Attribute.new('attr') }

    it 'returns the future value, unchanged' do
      expect(attribute.call('attr' => { 'future' => 5.0 })).to eq(5.0)
    end
  end # given no extractor block

  context 'given an extractor block' do
    let(:attribute) { Import::Attribute.new('attr') { |x, *| x * 5 } }

    it 'returns the return value of the block' do
      expect(attribute.call('attr' => { 'future' => 5.0 })).to eq(25.0)
    end
  end # given no extractor block

  context 'given only one name' do
    let(:attribute) { Import::Attribute.new('attr') }

    it 'sets the local name' do
      expect(attribute.local_name).to eq('attr')
    end

    it 'sets the remote name' do
      expect(attribute.local_name).to eq('attr')
    end

    it 'includes the names when calling inspect' do
      expect(attribute.inspect).to include('attr')
    end
  end # given only one name

  context 'given two names' do
    let(:attribute) { Import::Attribute.new('attr1', 'attr2') }

    it 'sets the local name with the first argument' do
      expect(attribute.local_name).to eq('attr1')
    end

    it 'sets the remote name with the second argument' do
      expect(attribute.remote_name).to eq('attr2')
    end

    it 'includes the names when calling inspect' do
      expect(attribute.inspect).to include('attr1')
      expect(attribute.inspect).to include('attr2')
    end
  end # given two names

  context 'given a nested hash name' do
    let(:attribute) { Import::Attribute.new('to', 'attr.thing') }

    context 'when the key is missing' do
      let(:data) { {} }

      it 'returns 0.0' do
        expect(attribute.call(data)).to eq(0.0)
      end
    end

    context 'when the nested hash is missing' do
      let(:data) { { 'attr' => {} } }

      it 'returns 0.0' do
        expect(attribute.call(data)).to eq(0.0)
      end
    end

    context 'when the subkey is missing' do
      let(:data) { { 'attr' => { 'future' => {} } } }

      it 'returns 0.0' do
        expect(attribute.call(data)).to eq(0.0)
      end
    end

    context 'when valid data is given' do
      let(:data) { { 'attr' => { 'future' => { 'thing' => 1.5 } } } }

      it 'returns the value' do
        expect(attribute.call(data)).to eq(1.5)
      end
    end
  end # given a nested hash name
end # describe Import::Attribute
