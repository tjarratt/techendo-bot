require_relative './base'

class VoteAction < BaseAction
  help_description do
    '!vote (topic_id) : vote on a topic'
  end

  args do
    [:message, /^!vote (\d+)$/]
  end

  action do |m, id|
    topic = Topic.find(id)
    unless topic
      return m.reply("sorry, I can't find that topic (#{id}), #{m.user.nick}")
    end

    votes = [Vote.find_by_topic_id(id) || []].flatten
    if votes.empty? || !votes.map(&:whom).include?(m.user.nick)
      Vote.create(
        :topic_id => id,
        :whom => m.user.nick
      )
      m.reply "#{m.user.nick} voted for topic #{id}"
    else
      m.reply "#{m.user.nick} already voted for topic #{id}"
    end
  end
end

class VoteListAction < BaseAction
  help_description do
    '!votes (--spam) : I will whisper the list of votes to you. Use --spam to spam the channel instead'
  end

  args do
    [:message, /^!votes( --spam)?$/]
  end

  action do |m, should_spam|
    all_votes = Vote.find(:all).to_a.inject({}) do |acc, v|
      acc[v.topic_id] ||= 0
      acc[v.topic_id] += 1
      acc
    end

    all_votes.sort_by {|k, v| v }.reverse.each do |topic, votes|
      message = "Topic (#{topic}) has #{votes} votes"

      if should_spam
        m.reply message
      else
        m.user.send message
      end
    end
  end
end
