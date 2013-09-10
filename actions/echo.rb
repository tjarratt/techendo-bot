require_relative './base'

class EchoAction < BaseAction
  def self.args
    [:message, /\!echo (.+)$/]
  end

  def self.action(m, message)
    return proc { Channel('#techendo').send(message) }
  end
end
