class BaseAction
  def self.args(&block)
    if block_given?
      @args = block
    else
      @args.call
    end
  end


  def self.action(*args, &block)
    if block_given?
      @action = block
    else
      @action.call(*args)
    end
  end

  def self.help_description(&block)
    if block_given?
      @help = block
    else
      @help.call unless @help.nil?
    end
  end

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
