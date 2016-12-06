# frozen_string_literal: true
require 'active_record/log_subscriber'

module Soliloquy
  module LogSubscribers
    class ActiveRecordLogSubscriber < ActiveRecord::LogSubscriber
      def sql(event)
        return unless logger.debug?
        self.class.runtime += event.duration
        payload = event.payload
        return if IGNORE_PAYLOAD_NAMES.include?(payload[:name]) || payload[:sql] =~ /SELECT "schema_migrations"/
        h = {
          msg: payload[:sql],
          duration: event.duration
        }
        debug h
      rescue => e
        error 'LogSubscriber error processing sql event', error_message: e.message, event: event
      end
    end
  end
end
