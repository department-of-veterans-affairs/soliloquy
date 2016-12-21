# frozen_string_literal: true
require 'spec_helper'

describe Soliloquy::Formatters::KeyValue do
  context 'with a action controller event' do
    let(:formatter) do
      Soliloquy::Formatters::KeyValue.format
    end

    it 'should output a key value message' do
      time = Time.now.utc
      expected = "[#{time.strftime('%Y-%m-%d %H:%M:%S')}] DEBUG : method=GET path=/v0/user status=200 \
controller=V0::UsersController action=show duration=3.83 view=1.98 db=0 session_id=0bea7e31efd042e8a500d584ffeeee90\n"
      expect(
        formatter.call(
          'DEBUG', time, 'my app',
          method: 'GET',
          path: '/v0/user',
          status: 200,
          controller: 'V0::UsersController',
          action: 'show',
          duration: 3.83,
          view: 1.98,
          db: 0,
          session_id: '0bea7e31efd042e8a500d584ffeeee90'
        )
      ).to eq(expected)
    end
  end
end
