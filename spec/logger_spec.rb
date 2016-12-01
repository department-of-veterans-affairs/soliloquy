# frozen_string_literal: true
require 'spec_helper'

describe Soliloquy::Logger do
  context 'when logging to STDOUT with default JSON formatter' do
    let(:logger) { Soliloquy::Logger.new(STDOUT) }
    let(:logging_methods) { %w(debug info warn error fatal) }
    let(:datetime_regex) { /\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}/ }

    describe 'logging methods' do
      context 'with no additional keys' do
        it 'should log a message' do
          logging_methods.each do |m|
            expect { logger.send(m, 'foo') }.to output(
              /{"t":"#{datetime_regex}","s":"#{m.upcase}","msg":"foo"}/
            ).to_stdout_from_any_process
          end
        end
      end
    end

    describe '.bind' do
      context 'given static data' do
        context 'when there are no previously bound keys' do
          it 'adds a bound key that is part of every log line' do
            expect { logger.bind(:app, 'my_app') }
              .to change { logger.instance_variable_get(:@bound_keys) }
                    .from({}).to(app: 'my_app')
            expect { logger.info 'foo', key: 'bar' }.to output(
              /{"t":"#{datetime_regex}","s":"INFO","msg":"foo","key":"bar","app":"my_app"}/
            ).to_stdout_from_any_process
          end
        end

        context 'when there are previously bound keys' do
          it 'adds another bound key that is part of every log line' do
            logger.instance_variable_set(:@bound_keys, app: 'my_app')
            expect { logger.bind(:service, 'my_service') }
              .to change { logger.instance_variable_get(:@bound_keys) }
                    .from(app: 'my_app').to(app: 'my_app', service: 'my_service')
            expect { logger.info 'foo', key: 'bar' }.to output(
              /{"t":"#{datetime_regex}","s":"INFO","msg":"foo","key":"bar","app":"my_app","service":"my_service"}/
            ).to_stdout_from_any_process
          end
        end
      end

      context 'given a closure' do
        let(:klass) do
          Class.new(Object) do
            attr_accessor :session_id
          end
        end
        let(:instance) { klass.new }
        it 'logs the value from the original scope' do
          instance.session_id = 'abc123'
          logger.bind(:session_id, lambda { instance.session_id })
          expect { logger.info 'foo', key: 'bar' }.to output(
            /{"t":"#{datetime_regex}","s":"INFO","msg":"foo","key":"bar","session_id":"abc123"}/
          ).to_stdout_from_any_process
          instance.session_id = 'xyz456'
          expect { logger.info 'foo', key: 'bar' }.to output(
            /{"t":"#{datetime_regex}","s":"INFO","msg":"foo","key":"bar","session_id":"xyz456"}/
          ).to_stdout_from_any_process
        end
      end
    end

    describe '.unbind' do
      context 'when there are no previously bound keys' do
        it 'bound_keys remains unchanged and does not raise an error' do
          expect { logger.unbind(:app) }
            .to_not change { logger.instance_variable_get(:@bound_keys) }
          expect { logger.unbind(:app) }
            .to_not raise_error
          expect { logger.info 'foo', key: 'bar' }.to output(
            /{"t":"#{datetime_regex}","s":"INFO","msg":"foo","key":"bar"}/
          ).to_stdout_from_any_process
        end
      end

      context 'when there are previously bound keys' do
        it 'removes the key and so it is not longer part of the output' do
          logger.instance_variable_set(:@bound_keys, app: 'my_app')
          expect { logger.info 'foo', key: 'bar' }.to output(
            /{"t":"#{datetime_regex}","s":"INFO","msg":"foo","key":"bar","app":"my_app"}/
          ).to_stdout_from_any_process
          expect { logger.unbind(:app) }
            .to change { logger.instance_variable_get(:@bound_keys) }
                  .from(app: 'my_app').to({})
          expect { logger.info 'foo', key: 'bar' }.to output(
            /{"t":"#{datetime_regex}","s":"INFO","msg":"foo","key":"bar"}/
          ).to_stdout_from_any_process
        end
      end
    end
  end
end
