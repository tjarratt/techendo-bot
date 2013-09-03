require_relative './base'

class HelpAction < BaseAction
  def self.args
    [:message, '!help']
  end

  def self._action(m)
    m.user.send 'Hello, I am the techendo bot. You can interact with me via these commands:'

    BaseAction.subclasses.each do |klass|
      message = klass.help_description
      m.user.send message unless str.empty?
    end
  end
end
