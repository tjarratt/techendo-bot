require_relative './base'

class HelpAction < BaseAction
  help_description do
    '!help : prints the commands this bot will respond to'
  end

  args do
    [:message, '!help']
  end

  action do |m|
    m.user.send 'Hello, I am the techendo bot. You can interact with me via these commands:'

    BaseAction.subclasses.each do |klass|
      message = klass.help_description
      m.user.send message unless message.nil? || message.empty?
    end
  end
end
