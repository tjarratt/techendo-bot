require 'cinch'
require 'topic'

Cinch::Bot.new do
  configure do |c|
    c.server = 'irc.freenode.org'
    c.channels = ['#techendo']
  end

  on(:message, 'topic') do |m, nick, message|
    Topic.create(
      :description => message,
      :author => nick,
    )
  end

  on(:message, 'topics') do |m|
    Topic.all.each do |t|
      m.reply "#{t.id} : #{t.description} (submitted by #{t.author})"
    end
  end
end.start
