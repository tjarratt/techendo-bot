#!/usr/bin/env ruby
require 'cinch'
require 'active_record'
require './topic'

ActiveRecord::Base.establish_connection(
  :adapter => 'PostgreSQL',
  :database => ENV["DATABASE_URL"]
)

puts "creating topics table"

begin
  ActiveRecord::Schema.define do
    create_table :topics do |table|
      table.column :id, :integer
      table.column :created_at, :datetime, :null => false, :default => Time.now
      table.column :author, :string
      table.column :description, :string
    end
  end
rescue Exception
  puts "No worries. Database already created."
end

unless Topic.create(:description => "hi", :author => "hi")
  puts "Sorry, that didn't work. There must be something wrong with me today."
else 
  puts "Recorded."
end


Cinch::Bot.new do
  configure do |c|
    c.server = 'irc.freenode.org'
    c.channels = ['#techendo']
    c.nick = 'techendo-pal'
  end

  on(:join) do |m|
    m.reply "Hi, everyone. How's it going?"
  end

  on(:message, 'you there, techendo-pal?') do |m|
    m.reply "Yes. I believe so."
  end

  on(:message, /^!topic (.+?) (.+)/) do |m, nick, message|
    puts nick
    puts message
    unless Topic.create(:description => message, :author => nick)
      m.reply "Sorry, that didn't work. There must be something wrong with me today."
    else 
      m.reply "Recorded topic: #{message}, by author: #{nick} at #{Time.now}"
    end
  end

  on(:message, '!topics') do |m|
    topics = Topic.find(:all)
    topics.each do |t|
      m.reply "#{t.id} : #{t.description} (submitted by #{t.author})"
    end
  end

end.start
