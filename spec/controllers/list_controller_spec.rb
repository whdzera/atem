require 'spec_helper'

RSpec.describe List do
  describe '.name' do
    before do
      allow(ENV).to receive(:fetch).and_call_original
      allow(ENV).to receive(:fetch).with('apiurl', nil).and_return('https://api.example.com')
      allow(ENV).to receive(:fetch).with('apikey', nil).and_return('test_token')
    end

    context 'with valid input' do
      it 'makes API request with correct parameters' do
        stub_request(:get, 'https://api.example.com/api/yugioh/list?name=Blue+Eyes')
          .with(headers: { 'Authorization' => 'Bearer test_token' })
          .to_return(status: 200, body: [{ 'name' => 'Blue Eyes White Dragon' }].to_json)

        result = List.name('Blue Eyes')
        expect(result).to be_an(Array)
      end

      it 'parses JSON response' do
        stub_request(:get, 'https://api.example.com/api/yugioh/list?name=Dragon')
          .with(headers: { 'Authorization' => 'Bearer test_token' })
          .to_return(status: 200, body: [{ 'name' => 'Dragon Card', 'type' => 'Synchro' }].to_json)

        result = List.name('Dragon')
        expect(result).to be_an(Array)
        expect(result[0]['name']).to eq('Dragon Card')
      end

      it 'supports only parameter' do
        stub_request(:get, 'https://api.example.com/api/yugioh/list?name=Test&only=monster')
          .with(headers: { 'Authorization' => 'Bearer test_token' })
          .to_return(status: 200, body: [].to_json)

        result = List.name('Test', only: 'monster')
        expect(result).to be_an(Array)
      end
    end

    context 'with invalid input' do
      it 'returns nil for nil input' do
        expect(List.name(nil)).to be_nil
      end

      it 'returns nil for empty string' do
        expect(List.name('')).to be_nil
      end

      it 'returns nil for whitespace only string' do
        expect(List.name('   ')).to be_nil
      end
    end

    context 'with API credentials missing' do
      before do
        allow(ENV).to receive(:fetch).and_call_original
        allow(ENV).to receive(:fetch).with('apiurl', nil).and_return(nil)
        allow(ENV).to receive(:fetch).with('apikey', nil).and_return(nil)
      end

      it 'returns nil when API URL is missing' do
        expect(List.name('test')).to be_nil
      end
    end

    context 'with HTTP errors' do
      before do
        allow(ENV).to receive(:fetch).and_call_original
        allow(ENV).to receive(:fetch).with('apiurl', nil).and_return('https://api.example.com')
        allow(ENV).to receive(:fetch).with('apikey', nil).and_return('test_token')
      end

      it 'returns nil on HTTP error' do
        stub_request(:get, 'https://api.example.com/api/yugioh/list?name=Test')
          .with(headers: { 'Authorization' => 'Bearer test_token' })
          .to_return(status: 404, body: 'Not Found')

        expect(List.name('Test')).to be_nil
      end
    end

    context 'with network errors' do
      before do
        allow(ENV).to receive(:fetch).and_call_original
        allow(ENV).to receive(:fetch).with('apiurl', nil).and_return('https://api.example.com')
        allow(ENV).to receive(:fetch).with('apikey', nil).and_return('test_token')
      end

      it 'returns nil on network error' do
        stub_request(:get, 'https://api.example.com/api/yugioh/list?name=Test')
          .to_raise(StandardError.new('Connection refused'))

        expect(List.name('Test')).to be_nil
      end
    end
  end
end
