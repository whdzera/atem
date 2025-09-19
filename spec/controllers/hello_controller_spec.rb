require 'spec_helper'

RSpec.describe Hello do
  describe '.say' do
    it 'returns the hello message' do
      expect(Hello.say).to eq('Hello, world!')
    end
  end
end
