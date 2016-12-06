# frozen_string_literal: true
require 'rails/railtie'
require 'action_view/log_subscriber'
require 'action_controller/log_subscriber'
require 'active_record/log_subscriber'

require 'soliloquy/overrides/rails/rack/logger'
require 'soliloquy/overrides/active_support/logger'
require 'soliloquy/overrides/action_controller/instrumentation'
require 'soliloquy/log_subscribers/action_controller_log_subscriber'
require 'soliloquy/log_subscribers/active_record_log_subscriber'

module Soliloquy
  class RailsConfig
    SUBSCRIBERS = %w(ActionController::LogSubscriber ActiveRecord::LogSubscriber ActionView::LogSubscriber).freeze

    class << self
      attr_accessor :additional_request_vars

      def add_request_var(var)
        @additional_request_vars ||= []
        @additional_request_vars << var
      end
    end

    def config
      unsubscribe_rails_default
      subscribe_soliloquy
    end

    private

    def unsubscribe_rails_default
      ActiveSupport::LogSubscriber.log_subscribers.each do |subscriber|
        unsubscribe(subscriber) if SUBSCRIBERS.include?(subscriber.class.to_s)
      end
    end

    def unsubscribe(subscriber)
      events = subscriber.instance_variable_get(:@patterns)
      listeners = events.flat_map { |e| ActiveSupport::Notifications.notifier.listeners_for(e) }
      listeners.each { |l| ActiveSupport::Notifications.unsubscribe l }
    end

    def subscribe_soliloquy
      Soliloquy::LogSubscribers::ActiveRecordLogSubscriber.attach_to :active_record
      Soliloquy::LogSubscribers::ActionControllerLogSubscriber.attach_to :action_controller
    end
  end
end

module Soliloquy
  class Railtie < Rails::Railtie
    config.after_initialize do |_app|
      Soliloquy::RailsConfig.new.config
    end
  end
end
