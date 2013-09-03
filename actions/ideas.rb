require_relative './safe_action'

class IdeaCreateAction < SafeAction
  def self.args
    [:message, /^!idea (.+)$/]
  end

  def self._action(m, message)
    unless Idea.create(:description => message, :author => m.user.nick)
      m.reply "Techendo is broken. Alert the authorities!"
    else
      m.reply "Recorded techendo idea: #{message}, by author: #{m.user.nick} at #{Time.now}"
    end
  end
end

class IdeaListAction < SafeAction
  def self.args
    [:message, /^!ideas( --spam)?$/]
  end

  def self._action(m, spam_channel)
    user = User(m.user.nick)
    ideas = Idea.find(:all)
    ideas.each do |t|
      message = "#{t.id} : #{t.description} (submitted by #{t.author})"
      if spam_channel
        m.reply message
      else
        user.send message
      end
    end
  end
end
