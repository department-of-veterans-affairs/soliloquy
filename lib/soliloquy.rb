# frozen_string_literal: true
require 'soliloquy/version'
require 'soliloquy/logger'

# Soliloquy module with a #logger method for building a Soliloquy::Logger instance
module Soliloquy
  # :nocov:

  # Builds a Soliloquy::Logger instance configured for use with plain old Ruby or Rails.
  # The Rails instance supports tagged logging, and condenses multiple related
  # ActionController events into one log line.
  # Rails ActiveRecord query events are also condensed, ActionView and ActiveSerializer events are silenced.
  #
  # @param logdev [IO, String] The log device. IO object (STDOUT) or filename (String)
  # @param shift_age [Integer, String] Number of old log files to keep, or frequency of rotation
  #   (daily, weekly or monthly). Default value is 0.
  # @param shift_size [Integer] Maximum logfile size in bytes (only applies when shift_age is a number).
  #   Defaults to 1048576 (1MB).
  # @param highlight [Boolean] Set to true to enable ANSI color syntax highlighting.
  #   Default is false and should be disabled for production logs.
  # @param formatter [Proc] Formats a log line. Default is Soliloquy::Formatters::JSONFormatter.
  def self.logger(
    logdev, shift_age = 7, shift_size = 1_048_576, highlight: false, formatter: Soliloquy::Formatters::JSON
  )
    if defined?(Rails)
      require 'soliloquy/railtie'
      ActiveSupport::TaggedLogging.new(
        Soliloquy::Logger.new(logdev, shift_age, shift_size, highlight: highlight, formatter: formatter)
      )
    else
      Soliloquy::Logger.new(logdev, shift_age, shift_size, highlight: highlight, formatter: formatter)
    end
  end
  # :nocov:
end
