class BaseAction
  def self.action(*args)
    begin
      _action(*args)
    rescue Exception => e
      return e
    end

    return false
  end

  # these methods should be implemented by subclasses
  def self._action; end
  def self.help_description; end

  def self.inherited(whom)
    @subclasses ||= []
    @subclasses << whom
  end

  def self.subclasses
    @subclasses
  end
end
