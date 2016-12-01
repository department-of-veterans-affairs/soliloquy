# frozen_string_literal: true
require 'rails/railtie'
require_relative 'log_subscribers/active_record_log_subscriber'
require_relative 'log_subscribers/action_controller_log_subscriber'

module Soliloquy
  class Railtie < Rails::Railtie
    config.after_initialize do |_app|
      Soliloquy::LogSubscribers::ActiveRecordLogSubscriber.attach_to :active_record
      Soliloquy::LogSubscribers::ActionControllerLogSubscriber.attach_to :action_controller
    end
  end
end
