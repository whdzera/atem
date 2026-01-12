require 'spec_helper'

RSpec.describe Random do
  describe '.card' do
    before do
      allow(ENV).to receive(:fetch).and_call_original
      allow(ENV).to receive(:fetch).with('apiurl', nil).and_return('https://api.example.com')
      allow(ENV).to receive(:fetch).with('apikey', nil).and_return('test_token')
    end

    context 'with valid API credentials' do
      it 'makes API request to random endpoint' do
        stub_request(:get, 'https://api.example.com/api/yugioh/random')
          .with(headers: { 'Authorization' => 'Bearer test_token' })
          .to_return(status: 200, body: { 'name' => 'Blue Eyes White Dragon', 'id' => 123 }.to_json)

        result = Random.card
        expect(result).to be_a(Hash)
      end

      it 'parses JSON response correctly' do
        stub_request(:get, 'https://api.example.com/api/yugioh/random')
          .with(headers: { 'Authorization' => 'Bearer test_token' })
          .to_return(status: 200, body: { 'name' => 'Dark Magician', 'level' => 7 }.to_json)

        result = Random.card
        expect(result['name']).to eq('Dark Magician')
        expect(result['level']).to eq(7)
      end

      it 'returns a different random card each call' do
        stub_request(:get, 'https://api.example.com/api/yugioh/random')
          .with(headers: { 'Authorization' => 'Bearer test_token' })
          .to_return(
            { status: 200, body: { 'name' => 'Card 1' }.to_json },
            { status: 200, body: { 'name' => 'Card 2' }.to_json }
          )

        result1 = Random.card
        result2 = Random.card
        expect(result1['name']).to eq('Card 1')
        expect(result2['name']).to eq('Card 2')
      end
    end

    context 'with missing API credentials' do
      before do
        allow(ENV).to receive(:fetch).and_call_original
        allow(ENV).to receive(:fetch).with('apiurl', nil).and_return(nil)
        allow(ENV).to receive(:fetch).with('apikey', nil).and_return(nil)
      end

      it 'returns nil when API URL is missing' do
        expect(Random.card).to be_nil
      end
    end

    context 'with HTTP errors' do
      before do
        allow(ENV).to receive(:fetch).and_call_original
        allow(ENV).to receive(:fetch).with('apiurl', nil).and_return('https://api.example.com')
        allow(ENV).to receive(:fetch).with('apikey', nil).and_return('test_token')
      end

      it 'returns nil on 4xx error' do
        stub_request(:get, 'https://api.example.com/api/yugioh/random')
          .with(headers: { 'Authorization' => 'Bearer test_token' })
          .to_return(status: 401, body: 'Unauthorized')

        expect(Random.card).to be_nil
      end

      it 'returns nil on 5xx error' do
        stub_request(:get, 'https://api.example.com/api/yugioh/random')
          .with(headers: { 'Authorization' => 'Bearer test_token' })
          .to_return(status: 500, body: 'Internal Server Error')

        expect(Random.card).to be_nil
      end
    end

    context 'with network errors' do
      before do
        allow(ENV).to receive(:fetch).and_call_original
        allow(ENV).to receive(:fetch).with('apiurl', nil).and_return('https://api.example.com')
        allow(ENV).to receive(:fetch).with('apikey', nil).and_return('test_token')
      end

      it 'returns nil on network error' do
        stub_request(:get, 'https://api.example.com/api/yugioh/random')
          .to_raise(StandardError.new('Connection timeout'))

        expect(Random.card).to be_nil
      end
    end
  end
end
