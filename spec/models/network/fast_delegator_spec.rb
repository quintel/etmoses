require 'rails_helper'

RSpec.describe Network::FastDelegator do
  let(:target_class) do
    Class.new do
      attr_accessor :accessor

      def no_args
        :result
      end

      def one_arg(value)
        value
      end

      def default_arg(value = :default)
        value
      end

      def splat(value, *splat)
        [value, splat]
      end
    end
  end

  let(:target)    { target_class.new }
  let(:delegator) { Network::FastDelegator.create(target_class) }
  let(:instance)  { delegator.new(target) }

  # --

  describe '.create' do
    it 'returns a Class' do
      expect(delegator).to be_a(Class)
    end
  end

  it 'delegates normal methods with no args' do
    expect(instance.no_args).to eq(target.no_args)
  end

  it 'delegates normal methods with non-zero args' do
    expect(instance.one_arg(:one)).to eq(target.one_arg(:one))
  end

  it 'delegates normal methods with args with default values' do
    expect(instance.default_arg).to eq(target.default_arg)
  end

  it 'delegates normal methods with splat args' do
    expect(instance.splat(1, 2, 3)).to eq(target.splat(1, 2, 3))
  end

  it 'delegates attr_accessors' do
    instance.accessor = :started
    expect(target.accessor).to eq(:started)

    target.accessor = :finished
    expect(instance.accessor).to eq(:finished)
  end
end
