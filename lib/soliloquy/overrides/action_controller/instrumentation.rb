# frozen_string_literal: true
ActionController::Instrumentation.class_eval do
  def process_action(*_args)
    raw_payload = {
      controller: self.class.name,
      action: action_name,
      params: request.filtered_parameters,
      format: request.format.try(:ref),
      method: request.request_method,
      path: begin
        request.fullpath
      rescue => _e
        'unknown'
      end
    }

    ActiveSupport::Notifications.instrument('process_action.action_controller', raw_payload) do |payload|
      begin
        result = super
        payload[:status] = response.status
        result
      ensure
        append_info_to_payload(payload)
      end
    end
  end
end
