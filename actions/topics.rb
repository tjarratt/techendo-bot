require_relative './base'

class TopicCreateAction < BaseAction
  help_description do
    '!topic (description of topic) : suggest a potential topic for techendo'
  end

  args do
    [:message, /^!topic (.+)$/]
  end

  action do |m, message|
    unless Topic.create(:description => message, :author => m.user.nick)
      m.reply "Sorry, that didn't work. There must be something wrong with me today."
    else
      m.reply "Recorded topic: #{message}, by author: #{m.user.nick} at #{Time.now}"
    end
  end
end

class TopicListAction < BaseAction
  help_description do
    '!topics (--spam) : I will whisper the list of topics to you. Use --spam to spam the channel instead'
  end

  args do
    [:message, /^!topics( --spam)?$/]
  end

  action do |m, spam_channel|
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
  help_description do
    '!delete topic (id) : delete a topic'
  end

  args do
    [:message, /^!delete topic (\d+)$/]
  end

  action do |m, id|
    puts id.inspect
    topic = Topic.find(id)
    if topic && (topic.author == m.user.nick || m.user.nick == "dpg")
      votes = [Vote.find_by_topic_id(id)].flatten.reject(&:nil?)
      votes.each(&:destroy)

      topic.destroy
      m.reply "Successfully destroyed #{topic.id}, by #{topic.author}"
    end
  end
end
