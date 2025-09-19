require 'spec_helper'

RSpec.describe Ping do
  describe '.calculate_latency' do
    it 'calculates correct latency in milliseconds' do
      start_time = Time.now
      Timecop.freeze(start_time + 1) do
        expect(Ping.calculate_latency(start_time)).to eq(1000)
      end
    end
  end

  describe '.say' do
    it 'returns the initial pong message' do
      expect(Ping.say).to eq('Pong!')
    end
  end

  describe '.with_latency' do
    it 'returns formatted message with latency' do
      expect(Ping.with_latency(100)).to eq('Pong! Latency: 100ms')
    end
  end
end
