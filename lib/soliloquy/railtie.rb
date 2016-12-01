# frozen_string_literal: true
require 'rails/railtie'
require_relative 'active_record_log_subscriber'
require_relative 'action_controller_log_subscriber'

module Soliloquy
  class Railtie < Rails::Railtie
    config.after_initialize do |_app|
      Soliloquy::ActiveRecordLogSubscriber.attach_to :active_record
      Soliloquy::ActionControllerLogSubscriber.attach_to :action_controller
    end
  end
end
