# frozen_string_literal: true
ActiveSupport::Notifications::Instrumenter.class_eval do
  def instrument(name, payload = {})
    start name, payload
    begin
      yield payload
    rescue Exception => e
      payload[:exception] = [e.class.name, e.message]
      raise e
    ensure
      finish name, payload
    end
  end
end
