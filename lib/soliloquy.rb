# frozen_string_literal: true
require 'soliloquy/version'
require 'soliloquy/logger'

module Soliloquy
  # :nocov:
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
