#!/usr/bin/env ruby
require 'uri'
require 'cinch'
require 'active_record'
require './topic'
require './vote'
require './tutorial'
require './database'

DatabaseHelper.connect
DatabaseHelper.migrate!

Cinch::Bot.new do
  configure do |c|
    c.server = 'irc.freenode.org'
    c.channels = ['#techendo']
    c.nick = 'techendo-pal'
  end


  on(:message, '!help') do |m|
    m.user.send 'Hello, I am the techendo bot. You can interact with me via these commands:'
    m.user.send '!topic (description of topic) : suggest a potential topic for techendo'
    m.user.send '!topics (--spam) : I will whisper the list of topics to you. Use --spam to spam the channel instead'
    m.user.send '!delete (topic_id) : delete a topic'
    m.user.send '!tutorial (description of tutorial) : suggest a potential tutorial for techendo'
    m.user.send '!tutorials (--spam) : I will whisper the list of tutorials to you. Use --spam to spam the channel instead'
    m.user.send '!delete tutorial (id) : delete a tutorial'
    m.user.send '!vote (topic_id) : vote on a topic'
    m.user.send '!votes (--spam) : I will whisper the list of votes to you. Use --spam to spam the channel instead'
  end

  on(:message, 'you there, techendo-pal?') do |m|
    m.reply "Yes. I believe so, #{m.user.name}. I visualize a time when we will be to robots what dogs are to humans, and I'm rooting for the machines."
  end

  on(:message, /^!idea (.+)$/) do |m, message|
    unless Idea.create(:description => message, :author => m.user.nick)
      m.reply "Techendo is broken. Alert the authorities"
    else
      m.reply "Recorded techendo idea: #{message}, by author: #{m.user.nick} at #{Time.now}"
    end
  end

  on(:message, /^!ideas( --spam)?$/) do |m, spam_channel|
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

  on(:message, /^!topic (.+)$/) do |m, message|
    unless Topic.create(:description => message, :author => m.user.nick)
      m.reply "Sorry, that didn't work. There must be something wrong with me today."
    else
      m.reply "Recorded topic: #{message}, by author: #{m.user.nick} at #{Time.now}"
    end
  end

  on(:message, /^!topics( --spam)?$/) do |m, spam_channel|
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

  on(:message, /^!delete topic (\d+)$/) do |m, id|
    topic = Topic.find(id)
    if topic && (topic.author == m.user.nick || m.user.nick == "dpg")
      votes = [Vote.find_by_topic_id(id)].flatten
      votes.each(&:destroy)

      topic.destroy
      m.reply "Successfully destroyed #{topic.id}, by #{topic.author}"
    end
  end

  on(:message, /^!tutorial (.+)$/) do |m, message|
    unless Tutorial.create(:description => message, :author => m.user.nick)
      m.reply "Sorry, that didn't work. There must be something wrong with me today."
    else
      m.reply "Recorded tutorial: #{message}, by author: #{m.user.nick} at #{Time.now}"
    end
  end

  on(:message, /^\!tutorials( --spam)?$/) do |m, spam_channel|
    Tutorial.find(:all).each do |t|
      message = "#{t.id} : #{t.description} (submitted by #{t.author})"

      if spam_channel
        m.reply message
      else
        m.user.send message
      end
    end
  end

  on(:message, /^!delete tutorial (\d+)$/) do |m, id|
    tut = Tutorial.find(id)
    if tut.author == m.user.nick || m.user.nick == "dpg"
      Tutorial.destroy(id)
      m.reply "Successfully destroyed tutorial: #{tut.id}, by #{tut.author}"
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
end.start
