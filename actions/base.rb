class BaseAction
  # these methods should be implemented by subclasses
  def self.action; end
  def self.help_description; end

  # used to reference all of the subclasses quickly
  # one of the many benefits of a dynamic language like ruby
  def self.inherited(whom)
    @subclasses ||= []
    @subclasses << whom
  end

  def self.subclasses
    @subclasses
  end
end
