require_relative './base'

class EchoAction < BaseAction
  args do
    [:message, /\!echo (.+)$/]
  end

  action do |m, message|
    return proc { Channel('#techendo').send(message) }
  end
end
