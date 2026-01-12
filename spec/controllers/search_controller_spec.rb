require 'spec_helper'

RSpec.describe Search do
  describe '.name' do
    before do
      allow(ENV).to receive(:fetch).and_call_original
      allow(ENV).to receive(:fetch).with('apiurl', nil).and_return('https://api.example.com')
      allow(ENV).to receive(:fetch).with('apikey', nil).and_return('test_token')
    end

    context 'with valid card name' do
      it 'makes API request with encoded card name' do
        stub_request(:get, 'https://api.example.com/api/yugioh/search?name=Blue+Eyes+White+Dragon')
          .with(headers: { 'Authorization' => 'Bearer test_token' })
          .to_return(status: 200, body: [{ 'name' => 'Blue Eyes White Dragon', 'id' => 89_631_139 }].to_json)

        result = Search.name('Blue Eyes White Dragon')
        expect(result).to be_an(Array)
      end

      it 'parses JSON response correctly' do
        stub_request(:get, 'https://api.example.com/api/yugioh/search?name=Dragon')
          .with(headers: { 'Authorization' => 'Bearer test_token' })
          .to_return(status: 200, body: [{ 'name' => 'Dragon Card', 'type' => 'Synchro Monster' }].to_json)

        result = Search.name('Dragon')
        expect(result[0]['name']).to eq('Dragon Card')
        expect(result[0]['type']).to eq('Synchro Monster')
      end

      it 'handles special characters in search term' do
        stub_request(:get, 'https://api.example.com/api/yugioh/search?name=R%26D%3A')
          .with(headers: { 'Authorization' => 'Bearer test_token' })
          .to_return(status: 200, body: [].to_json)

        result = Search.name('R&D:')
        expect(result).to be_an(Array)
      end
    end

    context 'with invalid input' do
      it 'returns nil for nil input' do
        expect(Search.name(nil)).to be_nil
      end

      it 'returns nil for empty string' do
        expect(Search.name('')).to be_nil
      end

      it 'returns nil for whitespace only string' do
        expect(Search.name('   ')).to be_nil
      end
    end

    context 'with missing API credentials' do
      before do
        allow(ENV).to receive(:fetch).and_call_original
        allow(ENV).to receive(:fetch).with('apiurl', nil).and_return(nil)
        allow(ENV).to receive(:fetch).with('apikey', nil).and_return(nil)
      end

      it 'returns nil when API URL is missing' do
        expect(Search.name('test')).to be_nil
      end
    end

    context 'with HTTP errors' do
      before do
        allow(ENV).to receive(:fetch).and_call_original
        allow(ENV).to receive(:fetch).with('apiurl', nil).and_return('https://api.example.com')
        allow(ENV).to receive(:fetch).with('apikey', nil).and_return('test_token')
      end

      it 'returns nil on 404 not found' do
        stub_request(:get, 'https://api.example.com/api/yugioh/search?name=InvalidCard')
          .with(headers: { 'Authorization' => 'Bearer test_token' })
          .to_return(status: 404, body: 'Not Found')

        expect(Search.name('InvalidCard')).to be_nil
      end

      it 'returns nil on 401 unauthorized' do
        stub_request(:get, 'https://api.example.com/api/yugioh/search?name=Test')
          .with(headers: { 'Authorization' => 'Bearer invalid_token' })
          .to_return(status: 401, body: 'Unauthorized')

        expect(Search.name('Test')).to be_nil
      end

      it 'returns nil on 500 server error' do
        stub_request(:get, 'https://api.example.com/api/yugioh/search?name=Test')
          .with(headers: { 'Authorization' => 'Bearer test_token' })
          .to_return(status: 500, body: 'Internal Server Error')

        expect(Search.name('Test')).to be_nil
      end
    end

    context 'with network errors' do
      before do
        allow(ENV).to receive(:fetch).and_call_original
        allow(ENV).to receive(:fetch).with('apiurl', nil).and_return('https://api.example.com')
        allow(ENV).to receive(:fetch).with('apikey', nil).and_return('test_token')
      end

      it 'returns nil on connection error' do
        stub_request(:get, 'https://api.example.com/api/yugioh/search?name=Test')
          .to_raise(StandardError.new('Connection refused'))

        expect(Search.name('Test')).to be_nil
      end
    end
  end
end
