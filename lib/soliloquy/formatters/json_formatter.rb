# frozen_string_literal: true
require_relative '../highlighter'

module Soliloquy
  module Formatters
    class JSON
      def self.format(highlight = false)
        highlighter = Soliloquy::JSONHighlighter if highlight
        proc do |severity, datetime, _progname, msg|
          h = {
            t: datetime.utc.strftime('%Y-%m-%d %H:%M:%S'),
            s: severity
          }
          h.merge! msg if msg.is_a? Hash
          message = "#{Oj.dump(h, mode: :compat)}\n"
          message = highlighter.highlight(message, severity) if highlighter
          message
        end
      end
    end
  end
end
