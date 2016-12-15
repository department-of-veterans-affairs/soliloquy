module ActiveSupport
  module TaggedLogging
    module Formatter
      def call(severity, timestamp, progname, msg)
        super(severity, timestamp, progname, msg, current_tags)
      end
    end
  end
end
