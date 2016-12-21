# frozen_string_literal: true
module Soliloquy
  # Base highlighter. Sub-classed highlighters will define a @pattern class instance variable
  # as a regular expression with capture groups to determine which elements of the line are highlighted.
  class Highlighter
    COLORS = {
      clear: "\e[0m",
      red: "\e[31m",
      green: "\e[32m",
      yellow: "\e[33m",
      magenta: "\e[35m",
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

    # Performs the message highlighting.
    #
    # @param message [String] the message to highlight
    # @param severity [Symbol] the level (color) to apply
    def self.highlight(message, severity)
      raise ArgumentError, 'subclass must define regex @pattern' unless @pattern
      color = COLOR_MAP[severity.downcase.to_sym]
      message.gsub(@pattern, "#{COLORS[color]}\\k<v>#{COLORS[:clear]}")
    end
  end

  # Highlights JSON formatted messages
  class JSONHighlighter < Highlighter
    @pattern = /(?<=:)(?<v>.*?)(?=(,"|}$))/
  end

  # Highlights key/value formatted messages
  class KeyValueHighlighter < Highlighter
    @pattern = /(?<=\[)(?<v>.*?)(?=\])|(?<=\]\s)(?<v>.*?)(?=\s:)|(?<=:\s)(?<v>.*?)(?=$)/
  end
end
