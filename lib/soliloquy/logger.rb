# frozen_string_literal: true
require 'logger'
require 'active_support'
require 'active_support/core_ext'
require 'oj'
require_relative 'formatters/json_formatter'
require_relative 'formatters/key_value_formatter'

module Soliloquy
  class Logger < Logger
    def initialize(
      logdev, shift_age = 7, shift_size = 1_048_576,
      highlight: false, formatter: Soliloquy::Formatters::JSON
    )
      super(logdev, shift_age, shift_size)
      self.formatter = formatter.format(highlight)
      @bound_keys = {}
    end

    def bind(key, value)
      @bound_keys[key] = value
    end

    def unbind(key)
      @bound_keys.delete key
    end

    def debug(*args, &block)
      return if args.all?(&:blank?)
      add(DEBUG, message_hash(args, &block))
    end

    def info(*args, &block)
      return if args.all?(&:blank?)
      add(INFO, message_hash(args, &block))
    end

    def warn(*args, &block)
      return if args.all?(&:blank?)
      add(WARN, message_hash(args, &block))
    end

    def error(*args, &block)
      return if args.all?(&:blank?)
      add(ERROR, message_hash(args, &block))
    end

    def fatal(*args, &block)
      return if args.all?(&:blank?)
      add(FATAL, message_hash(args, &block))
    end

    def add(severity, message = nil)
      severity ||= UNKNOWN
      return true if @logdev.nil? || severity < @level
      @logdev.write(
        format_message(format_severity(severity), Time.now.utc, nil, message)
      )
      true
    end

    private

    def message_hash(args, &_block)
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
      warn "failed to generate log message hash: #{e.message}"
    end

    def merge_bound_keys!(h)
      @bound_keys.each do |k, v|
        if v.respond_to? :call
          h.merge!(k => v.call) unless v.nil?
        else
          h.merge!(k => v) unless v.nil?
        end
      end
    end

    alias log add
  end
end

require_relative 'railtie' if defined?(Rails)
