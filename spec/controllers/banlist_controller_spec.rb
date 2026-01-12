require 'spec_helper'

RSpec.describe Banlist do
  describe '.scan' do
    it 'returns 3 for Unlimited' do
      expect(Banlist.scan('Unlimited')).to eq('3')
    end

    it 'returns 2 for Semi-Limited' do
      expect(Banlist.scan('Semi-Limited')).to eq('2')
    end

    it 'returns 1 for Limited' do
      expect(Banlist.scan('Limited')).to eq('1')
    end

    it 'returns 0 for Forbidden' do
      expect(Banlist.scan('Forbidden')).to eq('0')
    end

    it 'returns Undefined for unknown input' do
      expect(Banlist.scan('Unknown')).to eq('Undefined')
      expect(Banlist.scan('Invalid')).to eq('Undefined')
      expect(Banlist.scan('')).to eq('Undefined')
    end

    it 'is case-sensitive' do
      expect(Banlist.scan('unlimited')).to eq('Undefined')
      expect(Banlist.scan('LIMITED')).to eq('Undefined')
    end
  end
end
