# frozen_string_literal: true
require 'rails/railtie'
require_relative 'log_subscribers/active_record_log_subscriber'
require_relative 'log_subscribers/action_controller_log_subscriber'

# prevents double logging of events
ActiveSupport::Logger.class_eval do
  def self.broadcast(_logger)
    Module.new do
    end
  end
end

ActionController::Instrumentation.class_eval do
  def process_action(*_args)
    raw_payload = {
      controller: self.class.name,
      action: action_name,
      params: request.filtered_parameters,
      format: request.format.try(:ref),
      method: request.request_method,
      path: begin
        request.fullpath
      rescue => _e
        'unknown'
      end
    }

    ActiveSupport::Notifications.instrument('process_action.action_controller', raw_payload) do |payload|
      begin
        result = super
        payload[:status] = response.status
        payload[:session_id] = session_id if respond_to? :session_id
        result
      ensure
        append_info_to_payload(payload)
      end
    end
  end
end

module Soliloquy
  class Railtie < Rails::Railtie
    config.after_initialize do |_app|
      ActiveSupport::LogSubscriber.colorize_logging = false
      Soliloquy::LogSubscribers::ActiveRecordLogSubscriber.attach_to :active_record
      Soliloquy::LogSubscribers::ActionControllerLogSubscriber.attach_to :action_controller
    end
  end
end
