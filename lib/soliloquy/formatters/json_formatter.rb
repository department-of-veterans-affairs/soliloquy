# frozen_string_literal: true
require_relative '../highlighter'

module Soliloquy
  module Formatters
    class JSON
      def self.format(highlight = false)
        proc do |severity, datetime, _progname, msg|
          h = {
            datetime: datetime.utc.strftime('%Y-%m-%d %H:%M:%S'),
            severity: severity
          }
          h.merge! msg if msg.is_a? Hash
          message = "#{Oj.dump(h, mode: :compat)}\n"
          message = Soliloquy::JSONHighlighter.highlight(message, severity) if highlight
          message
        end
      end
    end
  end
end
