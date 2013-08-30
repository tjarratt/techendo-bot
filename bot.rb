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
end.start
