#!/usr/bin/env ruby
require 'cinch'
require 'active_record'
require './topic'
require './vote'
require './tutorial'

db = URI.parse(ENV['DATABASE_URL'] || 'postgres://localhost/mydb')

ActiveRecord::Base.establish_connection(
  :adapter  => db.scheme == 'postgres' ? 'postgresql' : db.scheme,
  :host     => db.host,
  :port     => db.port,
  :username => db.user,
  :password => db.password,
  :database => db.path[1..-1],
  :encoding => 'utf8'
)

def catches_exception(&block)
  begin
    block.call
  rescue ActiveRecord::StatementInvalid
    puts "No worries, this migration has already been run"
  end
end

puts "creating database"
ActiveRecord::Schema.define do
  catches_exception do
    create_table :topics do |table|
      table.column :id, :integer
      table.column :created_at, :datetime, :null => false, :default => Time.now
      table.column :author, :string
      table.column :description, :string
    end
  end

  catches_exception do
    create_table :votes do |t|
      t.column :topic_id, :integer
      t.column :whom, :string
    end
  end

  catches_exception do
    create_table :tutorials do |table|
      table.column :id, :integer
      table.column :created_at, :datetime, :null => false, :default => Time.now
      table.column :author, :string
      table.column :description, :string
    end
  end
end

Cinch::Bot.new do
  configure do |c|
    c.server = 'irc.freenode.org'
    c.channels = ['#techendo']
    c.nick = 'techendo-pal'
  end

  on(:message, 'you there, techendo-pal?') do |m|
    m.reply "Yes. I believe so, #{m.user.name}. I visualize a time when we will be to robots what dogs are to humans, and I'm rooting for the machines."
  end

  on(:message, /^!topic (.+)$/) do |m, message|
    unless Topic.create(:description => message, :author => m.user.nick)
      m.reply "Sorry, that didn't work. There must be something wrong with me today."
    else
      m.reply "Recorded topic: #{message}, by author: #{m.user.nick} at #{Time.now}"
    end
  end

  on(:message, /^\!topics( --spam)?$/) do |m, spam_channel|
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
      puts "destroying #{votes.size} votes"
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

  on(:message, '!tutorials') do |m|
    tut = Tutorial.find(:all)
    tut.each do |t|
      m.reply "#{t.id} : #{t.description} (submitted by #{t.author})"
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
