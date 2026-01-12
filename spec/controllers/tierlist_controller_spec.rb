require 'spec_helper'

RSpec.describe Tierlist do
  describe '.name' do
    before do
      allow(ENV).to receive(:fetch).and_call_original
      allow(ENV).to receive(:fetch).with('apiurl', nil).and_return('https://api.example.com')
      allow(ENV).to receive(:fetch).with('apikey', nil).and_return('test_token')
    end

    context 'with valid tier type' do
      it 'makes API request with tier type parameter' do
        stub_request(:get, 'https://api.example.com/api/yugioh/tierlist?name=S')
          .with(headers: { 'Authorization' => 'Bearer test_token' })
          .to_return(status: 200, body: [{ 'tier' => 'S', 'cards' => ['Blue Eyes White Dragon'] }].to_json)

        result = Tierlist.name('S')
        expect(result).to be_an(Array)
      end

      it 'parses JSON response correctly' do
        stub_request(:get, 'https://api.example.com/api/yugioh/tierlist?name=A')
          .with(headers: { 'Authorization' => 'Bearer test_token' })
          .to_return(status: 200, body: { 'tier' => 'A', 'count' => 50 }.to_json)

        result = Tierlist.name('A')
        expect(result['tier']).to eq('A')
        expect(result['count']).to eq(50)
      end

      it 'handles all tier types' do
        %w[S A B C D].each do |tier|
          stub_request(:get, "https://api.example.com/api/yugioh/tierlist?name=#{tier}")
            .with(headers: { 'Authorization' => 'Bearer test_token' })
            .to_return(status: 200, body: { 'tier' => tier }.to_json)

          result = Tierlist.name(tier)
          expect(result['tier']).to eq(tier)
        end
      end
    end

    context 'with missing API credentials' do
      before do
        allow(ENV).to receive(:fetch).and_call_original
        allow(ENV).to receive(:fetch).with('apiurl', nil).and_return(nil)
        allow(ENV).to receive(:fetch).with('apikey', nil).and_return(nil)
      end

      it 'returns nil when API URL is missing' do
        expect(Tierlist.name('S')).to be_nil
      end

      it 'returns nil when API token is missing' do
        allow(ENV).to receive(:fetch).with('apiurl', nil).and_return('https://api.example.com')
        allow(ENV).to receive(:fetch).with('apikey', nil).and_return(nil)

        expect(Tierlist.name('S')).to be_nil
      end
    end

    context 'with HTTP errors' do
      before do
        allow(ENV).to receive(:fetch).and_call_original
        allow(ENV).to receive(:fetch).with('apiurl', nil).and_return('https://api.example.com')
        allow(ENV).to receive(:fetch).with('apikey', nil).and_return('test_token')
      end

      it 'returns nil on 404 not found' do
        stub_request(:get, 'https://api.example.com/api/yugioh/tierlist?name=invalid')
          .with(headers: { 'Authorization' => 'Bearer test_token' })
          .to_return(status: 404, body: 'Not Found')

        expect(Tierlist.name('invalid')).to be_nil
      end

      it 'returns nil on 401 unauthorized' do
        stub_request(:get, 'https://api.example.com/api/yugioh/tierlist?name=S')
          .with(headers: { 'Authorization' => 'Bearer invalid_token' })
          .to_return(status: 401, body: 'Unauthorized')

        expect(Tierlist.name('S')).to be_nil
      end

      it 'returns nil on 500 server error' do
        stub_request(:get, 'https://api.example.com/api/yugioh/tierlist?name=S')
          .with(headers: { 'Authorization' => 'Bearer test_token' })
          .to_return(status: 500, body: 'Internal Server Error')

        expect(Tierlist.name('S')).to be_nil
      end
    end

    context 'with network errors' do
      before do
        allow(ENV).to receive(:fetch).and_call_original
        allow(ENV).to receive(:fetch).with('apiurl', nil).and_return('https://api.example.com')
        allow(ENV).to receive(:fetch).with('apikey', nil).and_return('test_token')
      end

      it 'returns nil on connection error' do
        stub_request(:get, 'https://api.example.com/api/yugioh/tierlist?name=S')
          .to_raise(StandardError.new('Connection timeout'))

        expect(Tierlist.name('S')).to be_nil
      end
    end
  end
end
