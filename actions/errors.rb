require_relative './safe_action'

class ErrorsAction < SafeAction
  @last_failure = nil
  @last_exception = nil

  def self.args
    [:message, '!errors']
  end

  def self.record_error(args)
    @last_failure, @last_exception = args
  end

  def self._action(m)
    unless @last_failure.nil?
      user = User(m.user.nick)
      user.send "Last failure was #{@last_failure}. Result : #{@last_exception.message}"
      user.send @last_exception.backtrace

      @last_failure = nil
      @last_exception = nil
    else
      m.reply "All systems operational"
    end
  end
end
