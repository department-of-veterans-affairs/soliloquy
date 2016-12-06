# frozen_string_literal: true
# TODO: investigate better way to prevent STDOUT double logging of events
ActiveSupport::Logger.class_eval do
  def self.broadcast(_logger)
    Module.new do
    end
  end
end
