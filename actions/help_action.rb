require_relative './safe_action'

class HelpAction < SafeAction
  def self.args
    [:message, '!help']
  end

  def self._action(m)
    m.user.send 'Hello, I am the techendo bot. You can interact with me via these commands:'
    m.user.send '!topic (description of topic) : suggest a potential topic for techendo'
    m.user.send '!topics (--spam) : I will whisper the list of topics to you. Use --spam to spam the channel instead'
    m.user.send '!delete (topic_id) : delete a topic'
    m.user.send '!tutorial (description of tutorial) : suggest a potential tutorial for techendo'
    m.user.send '!tutorials (--spam) : I will whisper the list of tutorials to you. Use --spam to spam the channel instead'
    m.user.send '!delete tutorial (id) : delete a tutorial'
    m.user.send '!vote (topic_id) : vote on a topic'
    m.user.send '!votes (--spam) : I will whisper the list of votes to you. Use --spam to spam the channel instead'
    m.user.send '!link (URL) : Logs the URL for the show'
    m.user.send '!links : Messages you with the last 20 links submitted'
    m.user.send '!mylinks : Messages you the last 10 links YOU submitted'
    m.user.send '!links (nick) : Messages you with the last 10 links submitted by the nick provided'
  end
end
