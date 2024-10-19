class EventLogger
  def initialize
    @logs = []
  end

  def log(event, messages, extra_data = {})
    log_entry = {
      timestamp: Time.now.utc.iso8601,
      event: event,
      messages: Array(messages)
    }

    log_entry.merge!(extra_data)

    @logs << log_entry 
  end

  def all_logs(event = nil)
    return @logs if event.nil?

    @logs.select { |log| log.event == event }
  end
end
