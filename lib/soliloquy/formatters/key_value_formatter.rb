# frozen_string_literal: true
require_relative '../highlighter'

module Soliloquy
  module Formatters
    class KeyValue
      def self.format(highlight = false)
        highlighter = Soliloquy::KeyValueHighlighter if highlight
        proc do |severity, datetime, _progname, msg|
          s = "[#{datetime.utc.strftime('%Y-%m-%d %H:%M:%S')}] #{severity} : "
          if msg.is_a? Hash
            s += "#{msg[:msg]} " unless msg[:msg].blank?
            msg.except(:msg).each do |k, v|
              s += "#{k}=#{v} "
            end
          else
            s += msg
          end
          message = "#{s}\n"
          message = highlighter.highlight(message, severity) if highlight
          message
        end
      end
    end
  end
end
