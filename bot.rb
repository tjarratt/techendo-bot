#!/usr/bin/env ruby
require 'uri'
require 'cinch'
require 'active_record'
require './database'
require './actions'

DatabaseHelper.connect
DatabaseHelper.migrate!

Cinch::Bot.new do
  configure do |c|
    c.server = 'irc.freenode.org'
    c.channels = ['#timecube']
    c.nick = 'techendo-pal2'
  end

  BaseAction.subclasses.each do |a|
    on(*a.args) do |*args|
      begin
        the_action = a.action(*args)
        self.instance_eval &the_action if the_action.instance_of? Proc
      rescue Exception => exception
        ErrorsAction.record_error(a.args.join(', '), exception)
        raise exception #xxx
      end
    end
  end
end.start
