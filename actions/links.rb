require_relative './base'

class CatchAllLinksAction < BaseAction
  def self.args
    [:catchall, /((([A-Za-z]{3,9}:(?:\/\/)?)(?:[-;:&=\+\$,\w]+@)?[A-Za-z0-9.-]+|(?:www.|[-;:&=\+\$,\w]+@)[A-Za-z0-9.-]+)((?:\/[\+~%\/.\w-_]*)?\??(?:[-\+=&;%@.\w_]*)#?(?:[\w]*))?)/]
  end

  def self.action(*args)
    m  = args.first
    #checks for !link command and skips if present
    if m.message.match(/^!link/)
      successfully_created = Link.create(
        :url => url,
        :author => m.user.nick,
        :showlink => false
      )
      if successfully_created
        m.reply "Do a solid and add this link to the facebook page: http://facebook/techendo. I logged #{link} from #{m.user.nick} to our URL repo at #{Time.now}."
      end
    end
  end
end

class LinkCreateAction < BaseAction
  def self.help_description
    '!link (URL) : Logs the URL for the show'
  end

  def self.args
    [:message, /^!link (.+)$/]
  end

  def self.action(m, url)
    if url.match(/^https?:\/\/([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$/)
      successfully_created = Link.create(
        :url => url,
        :author => m.user.nick,
        :showlink => true
      )
      if successfully_created
        m.reply "Logged #{url} from #{m.user.nick}. Spanx!"
      end
    else
      m.reply "Yo link don't jive with my insides."
    end
  end
end

class LinkPrintAction < BaseAction
  def self.help_description
    '!links : Messages you with the last 20 links submitted'
  end

  def self.args
    [:message, /^!(mylinks|prismlinks)$/]
  end

  def self.action(m, capture)
    #messages you the past 20 links you submitted
    if m.message.match(/^!mylinks$/)
      links = Link.where(showlink: true, author: m.user.nick).last(10)
      links.each do |link|
        message = "#{link.url} : #{link.created_at} (submitted by #{link.author})"
        m.user.send message
        #end spam if else
      end #links printing

    #messages you the past 30 links logged and submitted
    else m.message.match(/^!prismlinks$/)
      links = Link.last(30)
      links.each do |link|
        message = "#{link.url} : #{link.created_at} (submitted by #{link.author})"
        m.user.send message
      end
    end
  end
end

class PrintUsersLinksAction < BaseAction
  def self.help_description
    '!links (nick) : Messages you with the last 10 links submitted by the nick provided'
  end

  def self.args
    [:message, /^!links( .+)?$/]
  end

  def self.action(m, nick_name)
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
      m.user.send message
    end
  end
end
