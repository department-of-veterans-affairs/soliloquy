# frozen_string_literal: true
require 'spec_helper'

describe Soliloquy::Logger do
  context 'with a JSON pattern' do
    let(:xml_highlighter) do
      Class.new(Soliloquy::Highlighter) do
        @pattern = /(?<=<xml>)(?<v>.*?)(?=<\/xml>)/
      end
    end
    let(:message) { '<xml>foo</xml>' }
    let(:severity) { 'ERROR' }

    it 'should add ANSI highlighting' do
      expect(xml_highlighter.highlight(message, severity)).to eq("<xml>\e[31mfoo\e[0m</xml>")
    end
  end
end
