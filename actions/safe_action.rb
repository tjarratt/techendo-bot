class SafeAction
  def self.action
    the_action = proc do |args|
      return_value = false

      begin
        _action(*args)
      rescue Exception => e
        return_value = e
      end

      return_value
    end

    return the_action
  end

  # this method should be implemented by subclasses
  def self._action
  end
end
