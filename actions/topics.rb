require_relative './safe_action'

class TopicCreateAction < SafeAction
  def self.args
    [:message, /^!topic (.+)$/]
  end

  def self._action(m, message)
    unless Topic.create(:description => message, :author => m.user.nick)
      m.reply "Sorry, that didn't work. There must be something wrong with me today."
    else
      m.reply "Recorded topic: #{message}, by author: #{m.user.nick} at #{Time.now}"
    end
  end
end

class TopicListAction < SafeAction
  def self.args
    [:message, /^!topics( --spam)?$/]
  end

  def self._action(m, spam_channel)
    user = User(m.user.nick)

    topics = Topic.find(:all)
    topics.each do |t|
      message = "#{t.id} : #{t.description} (submitted by #{t.author})"
      if spam_channel
        m.reply message
      else
        user.send message
      end
    end
  end
end


class TopicDeleteAction < SafeAction
  def self.args
    [:message, /^!delete topic (\d+)$/]
  end

  def self._action(m, id)
    topic = Topic.find(id)
    if topic && (topic.author == m.user.nick || m.user.nick == "dpg")
      votes = [Vote.find_by_topic_id(id)].flatten
      votes.each(&:destroy)

      topic.destroy
      m.reply "Successfully destroyed #{topic.id}, by #{topic.author}"
    end
  end
end
