#!/usr/bin/env ruby
require 'uri'
require 'cinch'
require 'active_record'
require './topic'
require './vote'
require './tutorial'
require './idea'
require './database'
require './links'
require './actions'

DatabaseHelper.connect
DatabaseHelper.migrate!

Cinch::Bot.new do
  configure do |c|
    c.server = 'irc.freenode.org'
    c.channels = ['#techendo']
    c.nick = 'techendo-pal'
  end

  SafeAction.subclasses.each do |a|
    on(*a.args) do |args|
      if failure = a.action.call(*args)
        ErrorsAction.record_error(a.args.join(', '), failure)
      end
    end
  end

  on(:message, /^!vote (\d+)$/) do |m, id|
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

  on(:message, /^!votes( --spam)?$/) do |m, should_spam|
    user = User(m.user.nick)

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
        user.send message
      end
    end
  end

  #munching on URLs Prism style - fails for URLs with parameters
  on(:catchall, /((([A-Za-z]{3,9}:(?:\/\/)?)(?:[-;:&=\+\$,\w]+@)?[A-Za-z0-9.-]+|(?:www.|[-;:&=\+\$,\w]+@)[A-Za-z0-9.-]+)((?:\/[\+~%\/.\w-_]*)?\??(?:[-\+=&;%@.\w_]*)#?(?:[\w]*))?)/
  ) do |m|
    #checks for !link command and skips if present
    if m.message.match(/^!link/)
    else
      links = URI.extract(m.message)
      links.each { |link|
        Link.create(
            :url => link,
            :author => m.user.nick,
            :showlink => false
          )
      log "We added #{link} from #{m.user.nick} to our URL repo at #{Time.now}."
      }
    end #end Check for !link
  end #end LinkCatching

  #capture links for Techendo via PM
  on(:message, /^!link (.+)$/) do |m, url|
    log url
    if (/^https?:\/\/([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$/.match url)
      Link.create(
          :url => url,
          :author => m.user.nick,
          :showlink => true
        )
      m.reply "Logged #{url} from #{m.user.nick}. Spanx!"
    else
      m.reply "Yo link don't jive with my insides."
    end #end links if
  end #end LinkCatching

  #print the last 20 links submitted by date
  on(:message, /^!(mylinks|prismlinks)$/) do |m|
    user = User(m.user.nick)

    #messages you the past 20 links you submitted
    if m.message.match(/^!mylinks$/)
      links = Link.where(showlink: true, author: m.user.nick).last(10)
      links.each do |link|
        message = "#{link.url} : #{link.created_at} (submitted by #{link.author})"
        user.send message
        #end spam if else
      end #links printing

    #messages you the past 30 links logged and submitted
    else m.message.match(/^!prismlinks$/)
      links = Link.last(30)
      links.each do |link|
        message = "#{link.url} : #{link.created_at} (submitted by #{link.author})"
        user.send message
      end #links printing
    end #end sorting print command
  end #end printing do

  on(:message, /^!links( .+)?$/) do |m, nick_name|
    user = User(m.user.nick)

    if nick_name
      #messages you the past 10 links submitted
      nick_name = nick_name.strip
      links = Link.where(showlink: true, author: nick_name).last(10)
    else
      #messages you the past 20 links submitted. Probably is going to trigger flood protection.
      links = Link.where(showlink: true).last(20)
    end
    links.each do |link|
      message = "#{link.url} : #{link.created_at} (submitted by #{link.author})"
      user.send message
    end #links printing
  end #end showing links
end.start
