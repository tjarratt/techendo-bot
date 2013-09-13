require_relative './base'

class IdeaCreateAction < BaseAction
  args do
    [:message, /^!idea (.+)$/]
  end

  action do |m, message|
    unless Idea.create(:description => message, :author => m.user.nick)
      m.reply "Techendo is broken. Alert the authorities!"
    else
      m.reply "Recorded techendo idea: #{message}, by author: #{m.user.nick} at #{Time.now}"
    end
  end
end

class IdeaListAction < BaseAction
  args do
    [:message, /^!ideas( --spam)?$/]
  end

  action do |m, spam_channel|
    ideas = Idea.find(:all)
    ideas.each do |t|
      message = "#{t.id} : #{t.description} (submitted by #{t.author})"
      if spam_channel
        m.reply message
      else
        m.user.send message
      end
    end
  end
end
