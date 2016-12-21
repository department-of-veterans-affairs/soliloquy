# frozen_string_literal: true
require_relative '../highlighter'

module Soliloquy
  module Formatters
    # Formats messages as key value pairs
    class KeyValue
      def self.format(highlight = false)
        proc do |severity, datetime, _progname, msg, tags|
          s = "[#{datetime.utc.strftime('%Y-%m-%d %H:%M:%S')}] #{severity} : "
          if msg.is_a? Hash
            s += "#{msg[:msg]} " unless msg[:msg].blank?
            s += msg.except(:msg).map { |k, v| "#{k}=#{v}" }.join(' ')
          else
            s += msg
          end
          s += tags.reduce({}, :merge).map { |k, v| "#{k}=#{v}" }.join(' ') if tags
          message = "#{s}\n"
          message = Soliloquy::KeyValueHighlighter.highlight(message, severity) if highlight
          message
        end
      end
    end
  end
end
