# frozen_string_literal: true
module Soliloquy
  class Highlighter
    COLORS = {
      clear: "\e[0m",
      bold: "\e[1m",
      red: "\e[31m",
      green: "\e[32m",
      yellow: "\e[33m",
      blue: "\e[34m",
      magenta: "\e[35m",
      cyan: "\e[36m",
      white: "\e[37m"
    }.freeze

    COLOR_MAP = {
      debug: :green,
      info: :clear,
      warn: :yellow,
      error: :red,
      fatal: :magenta,
      any: :white
    }.freeze

    def self.highlight(message, severity)
      raise ArgumentError, 'subclass must define regex @pattern' unless @pattern
      color = COLOR_MAP[severity.downcase.to_sym]
      message.gsub(@pattern, "#{COLORS[color]}\\k<v>#{COLORS[:clear]}")
    end
  end

  class JSONHighlighter < Highlighter
    @pattern = /(?<=:)(?<v>.*?)(?=(,"|}$))/
  end

  class KeyValueHighlighter < Highlighter
    @pattern = /(?<=\[)(?<v>.*?)(?=\])|(?<=\]\s)(?<v>.*?)(?=\s:)|(?<=:\s)(?<v>.*?)(?=$)/
  end
end
