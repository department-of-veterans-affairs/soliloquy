# frozen_string_literal: true
require 'active_support/log_subscriber'

module Soliloquy
  module LogSubscribers
    class ActionControllerLogSubscriber < ActiveSupport::LogSubscriber
      def process_action(event)
        duration = event.duration.nil? ? nil : format('%.2f', event.duration)
        view_runtime = event.payload[:view_runtime].blank? ? nil : format('%.2f', event.payload[:view_runtime])
        db_runtime = event.payload[:db_runtime].blank? ? nil : format('%.2f', event.payload[:db_runtime])
        h = {
          method: event.payload[:method],
          path: event.payload[:path],
          status: event.payload[:status],
          controller: event.payload[:controller],
          action: event.payload[:action],
          duration: duration,
          view: view_runtime,
          db: db_runtime
        }
        h[:session_id] = event.payload[:session_id] if event.payload.key?(:session_id)
        info h
      rescue => e
        error 'LogSubscriber error processing action event', error_message: e.message, event: event
      end
    end
  end
end
