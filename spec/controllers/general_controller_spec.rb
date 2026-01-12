require 'spec_helper'

RSpec.describe General do
  describe '.info' do
    it 'returns bot information string' do
      info = General.info
      expect(info).to include('Atem bot')
      expect(info).to include('1.1.0')
      expect(info).to include('Ruby Language')
      expect(info).to include('whdzera')
    end

    it 'includes all required sections' do
      info = General.info
      expect(info).to include('*Name*')
      expect(info).to include('*Version*')
      expect(info).to include('*Description*')
      expect(info).to include('*Written in*')
      expect(info).to include('*Developed by*')
    end
  end

  describe '.help' do
    it 'returns help message' do
      help = General.help
      expect(help).to include('Atem Bot')
      expect(help).to include('/info')
      expect(help).to include('/ping')
      expect(help).to include('/random')
    end

    it 'includes all available commands' do
      help = General.help
      expect(help).to include('/art')
      expect(help).to include('/img')
      expect(help).to include('/list')
      expect(help).to include('/search')
      expect(help).to include('/tier')
    end
  end

  describe '.sourcecode' do
    it 'returns github repository URL' do
      expect(General.sourcecode).to eq('https://github.com/whdzera/atem')
    end
  end

  describe '.escape_markdown' do
    it 'escapes underscore' do
      expect(General.escape_markdown('_text_')).to eq('\\_text\\_')
    end

    it 'escapes asterisk' do
      expect(General.escape_markdown('*bold*')).to eq('\\*bold\\*')
    end

    it 'escapes brackets' do
      expect(General.escape_markdown('[link]')).to eq('\\[link\\]')
    end

    it 'escapes parentheses' do
      expect(General.escape_markdown('(text)')).to eq('\\(text\\)')
    end

    it 'escapes backtick' do
      expect(General.escape_markdown('`code`')).to eq('\\`code\\`')
    end

    it 'escapes multiple special characters' do
      expect(General.escape_markdown('*bold _italic_*')).to eq('\\*bold \\_italic\\_\\*')
    end

    it 'escapes all markdown special characters' do
      text = '_*[]()~`>#+\\-=|{}.!'
      expected = '\\_\\*\\[\\]\\(\\)\\~\\`\\>\\#\\+\\\\\\-\\=\\|\\{\\}\\.\\!'
      expect(General.escape_markdown(text)).to eq(expected)
    end

    it 'returns plain text unchanged if no special characters' do
      expect(General.escape_markdown('plain text')).to eq('plain text')
    end
  end
end
