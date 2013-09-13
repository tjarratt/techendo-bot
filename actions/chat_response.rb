require_relative './base'

class ChatResponseAction < BaseAction
  args do
    [:message, /techendo\-pal/]
  end

  action do |m|
    if m.message.match(/you there, techendo\-pal\?/)
      m.reply "Yes. I believe so, #{m.user.name}. I visualize a time when we will be to robots what dogs are to humans, and I'm rooting for the machines."
    else
      m.reply "You know I can hear you talking about me, right?"
    end
  end
end
