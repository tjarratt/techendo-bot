require_relative './base'

class ErrorsAction < BaseAction
  @last_failure = nil
  @last_exception = nil

  def self.help_description
    '!errors : Will print the last error, with backtrace'
  end

  def self.args
    [:message, '!errors']
  end

  def self.record_error(message, backtrace)
    @last_failure = message
    @last_exception = backtrace
  end

  def self.action(m)
    unless @last_failure.nil?
      m.user.send "Last failure was #{@last_failure}. Result : #{@last_exception.message}"
      m.user.send @last_exception.backtrace

      @last_failure = nil
      @last_exception = nil
    else
      m.reply "All systems operational"
    end
  end
end
