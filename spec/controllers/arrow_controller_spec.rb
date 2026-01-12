require 'spec_helper'

RSpec.describe Arrow do
  describe '.scan' do
    context 'when input is an Array' do
      it 'converts array of directions to arrow symbols' do
        expect(Arrow.scan(%w[Top Bottom Left Right])).to eq('↑ ↓ ← →')
      end

      it 'handles single element array' do
        expect(Arrow.scan(['Top'])).to eq('↑')
      end

      it 'handles mixed valid and invalid directions' do
        expect(Arrow.scan(%w[Top Invalid])).to eq('↑ Invalid')
      end

      it 'returns empty string for empty array' do
        expect(Arrow.scan([])).to eq('')
      end
    end

    context 'when input is a String' do
      it 'converts top to up arrow' do
        expect(Arrow.scan('Top')).to eq('↑')
      end

      it 'converts bottom to down arrow' do
        expect(Arrow.scan('Bottom')).to eq('↓')
      end

      it 'converts left to left arrow' do
        expect(Arrow.scan('Left')).to eq('←')
      end

      it 'converts right to right arrow' do
        expect(Arrow.scan('Right')).to eq('→')
      end

      it 'converts diagonal directions' do
        expect(Arrow.scan('Top-Left')).to eq('↖')
        expect(Arrow.scan('Top-Right')).to eq('↗')
        expect(Arrow.scan('Bottom-Left')).to eq('↙')
        expect(Arrow.scan('Bottom-Right')).to eq('↘')
      end

      it 'returns original string if direction not found' do
        expect(Arrow.scan('Invalid')).to eq('Invalid')
      end
    end

    context 'when input is neither Array nor String' do
      it 'returns dash for other types' do
        expect(Arrow.scan(123)).to eq('-')
        expect(Arrow.scan(nil)).to eq('-')
        expect(Arrow.scan({})).to eq('-')
      end
    end
  end
end
