# frozen_string_literal: true
require 'logger'
require 'active_support'
require 'active_support/core_ext'
require 'oj'
require_relative 'formatters/json_formatter'
require_relative 'formatters/key_value_formatter'

module Soliloquy
  # Outputs structured messages with various log levels to a log device.
  class Logger < Logger
    # Build a logger instance.
    #
    # @param logdev [IO or String] The log device. IO object (STDOUT) or filename (String)
    # @param shift_age [Integer, String] Number of old log files to keep, or frequency of rotation
    #   (daily, weekly or monthly). Default value is 0.
    # @param shift_size [Integer] Maximum logfile size in bytes (only applies when shift_age is a number).
    #   Defaults to 1048576 (1MB).
    # @param highlight [Boolean] Set to true to enable ANSI color syntax highlighting.
    #   Default is false and should be disabled for production logs.
    # @param formatter [Proc] Formats a log line. Default is Soliloquy::Formatters::JSONFormatter.
    def initialize(
      logdev, shift_age = 7, shift_size = 1_048_576, highlight: false, formatter: Soliloquy::Formatters::JSON
    )
      super(logdev, shift_age, shift_size)
      self.formatter = formatter.format(highlight)
      @bound_keys = {}
    end

    # binds a value via a key that will be outputted with every log line
    #
    # @param key [Symbol, String] the key for the bound value
    # @param value [Object] Can be any object including a Proc,
    #   Proc's are useful for setting values that change over time
    #   but need to be evaluated from the context in which it was created.
    def bind(key, value)
      @bound_keys[key] = value
    end

    # Removes a bound value so it is no longer outputted with each line.
    #
    # @param key [Symbol, String] the key for the bound value to remove.
    def unbind(key)
      @bound_keys.delete key
    end

    # Logs a DEBUG level message
    #
    # @param args one or more messages to log. The first message receives the +:msg+ key,
    #   subsequent messages should be passed in as a hash
    # @param block Can be omitted. Called to get a message string if args is nil
    # @example log a debug message
    #   logger.debug "Something happened", id: 'abc123', foo: 'bar'
    def debug(*args, &block)
      add(DEBUG, message_hash(args, &block))
    end

    # Logs a INFO level message. see #debug
    def info(*args, &block)
      add(INFO, message_hash(args, &block))
    end

    # Logs a WARN level message. see #debug
    def warn(*args, &block)
      add(WARN, message_hash(args, &block))
    end

    # Logs a ERROR level message. see #debug
    def error(*args, &block)
      add(ERROR, message_hash(args, &block))
    end

    # Logs a FATAL level message. see #debug
    def fatal(*args, &block)
      add(FATAL, message_hash(args, &block))
    end

    private

    def add(severity, message = nil)
      severity ||= UNKNOWN
      return true if @logdev.nil? || severity < @level
      @logdev.write(format_message(format_severity(severity), Time.now.utc, nil, message))
      true
    end

    def message_hash(args)
      h = if args[0].is_a? Hash
            args[0]
          elsif args[0].nil? && block_given?
            { msg: yield }
          else
            head, *tail = args
            { msg: head }.merge(tail.reduce({}, :update))
          end
      merge_bound_keys!(h)
      h
    rescue StandardError => e
      warn "Failed to generate log message hash: #{e.message}"
    end

    def merge_bound_keys!(h)
      @bound_keys.each do |k, v|
        if v.respond_to? :call
          h.merge!(k => v.call) unless v.nil?
        else
          h.merge!(k => v)
        end
      end
    end

    alias log add
  end
end
