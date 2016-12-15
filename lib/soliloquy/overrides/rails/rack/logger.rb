# frozen_string_literal: true
module Rails
  module Rack
    class Logger
      def call_app(request, env)
        resp = @app.call(env)
        resp[2] = ::Rack::BodyProxy.new(resp[2]) { finish(request) }
        resp
      rescue Exception
        raise
      ensure
        ActiveSupport::LogSubscriber.flush_all!
      end

      protected

      def compute_tags(request)
        request_tags = {}
        @taggers.each do |tag|
          case tag
          when Proc
            (request_tags[:tag] ||= []) << tag.call(request)
          when Symbol
            request_tags[tag] = request.send(tag)
          else
            (request_tags[:tag] ||= []) << tag
          end
        end
        request_tags
      end
    end
  end
end
