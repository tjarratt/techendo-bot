class TutorialCreateAction < SafeAction
  def self.args
    [:message, /^!tutorial (.+)$/]
  end

  def self._action(m, message)
    unless Tutorial.create(:description => message, :author => m.user.nick)
      m.reply "Sorry, that didn't work. There must be something wrong with me today."
    else
      m.reply "Recorded tutorial: #{message}, by author: #{m.user.nick} at #{Time.now}"
    end
  end
end

class TutorialListAction < SafeAction
  def self.args
    [:message, /^\!tutorials( --spam)?$/]
  end

  def self._action(m, spam_channel)
    Tutorial.find(:all).each do |t|
      message = "#{t.id} : #{t.description} (submitted by #{t.author})"

      if spam_channel
        m.reply message
      else
        m.user.send message
      end
    end
  end
end

class TutorialDeleteAction < SafeAction
  def self.args
    [:message, /^!delete tutorial (\d+)$/]
  end

  def self._action(m, id)
    tut = Tutorial.find(id)
    if tut.author == m.user.nick || m.user.nick == "dpg"
      Tutorial.destroy(id)
      m.reply "Successfully destroyed tutorial: #{tut.id}, by #{tut.author}"
    end
  end
end
