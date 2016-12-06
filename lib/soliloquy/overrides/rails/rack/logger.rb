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
    end
  end
end
