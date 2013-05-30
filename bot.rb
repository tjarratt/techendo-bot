require 'cinch'
require 'topic'
require 'active_record'

ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3',
  :database => ':memory:'
)

ActiveRecord::Schema.define do
  create_table :topics do |table|
    table.column :id, :integer
    table.column :created_at, :datetime, :null => false, :default => Time.now
    table.column :author, :string
    table.column :description, :string
  end
end

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
