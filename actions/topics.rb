require_relative './base'

class TopicCreateAction < BaseAction
  def self.help_description
    '!topic (description of topic) : suggest a potential topic for techendo'
  end

  def self.args
    [:message, /^!topic (.+)$/]
  end

  def self.action(m, message)
    unless Topic.create(:description => message, :author => m.user.nick)
      m.reply "Sorry, that didn't work. There must be something wrong with me today."
    else
      m.reply "Recorded topic: #{message}, by author: #{m.user.nick} at #{Time.now}"
    end
  end
end

class TopicListAction < BaseAction
  def self.help_description
    '!topics (--spam) : I will whisper the list of topics to you. Use --spam to spam the channel instead'
  end

  def self.args
    [:message, /^!topics( --spam)?$/]
  end

  def self.action(m, spam_channel)
    topics = Topic.find(:all)
    topics.each do |t|
      message = "#{t.id} : #{t.description} (submitted by #{t.author})"
      if spam_channel
        m.reply message
      else
        m.user.send message
      end
    end
  end
end


class TopicDeleteAction < BaseAction
  def self.help_description
    '!delete (topic_id) : delete a topic'
  end

  def self.args
    [:message, /^!delete topic (\d+)$/]
  end

  def self.action(m, id)
    topic = Topic.find(id)
    if topic && (topic.author == m.user.nick || m.user.nick == "dpg")
      votes = [Vote.find_by_topic_id(id)].flatten
      votes.each(&:destroy)

      topic.destroy
      m.reply "Successfully destroyed #{topic.id}, by #{topic.author}"
    end
  end
end
