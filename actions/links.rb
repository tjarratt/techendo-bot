require_relative './safe_action'

class CatchAllLinksAction < SafeAction
  def self.args
    [:catchall, /((([A-Za-z]{3,9}:(?:\/\/)?)(?:[-;:&=\+\$,\w]+@)?[A-Za-z0-9.-]+|(?:www.|[-;:&=\+\$,\w]+@)[A-Za-z0-9.-]+)((?:\/[\+~%\/.\w-_]*)?\??(?:[-\+=&;%@.\w_]*)#?(?:[\w]*))?)/]
  end

  def self._action(m)
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
    end
  end
end

class LinkCreateAction < SafeAction
  def self.args
    [:message, /^!link (.+)$/]
  end

  def self._action(m, url)
    if (/^https?:\/\/([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$/.match url)
      Link.create(
          :url => url,
          :author => m.user.nick,
          :showlink => true
        )
      m.reply "Logged #{url} from #{m.user.nick}. Spanx!"
    else
      m.reply "Yo link don't jive with my insides."
    end
  end
end

class LinkPrintAction < SafeAction
  def self.args
    [:message, /^!(mylinks|prismlinks)$/]
  end

  def self._action(m)
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
      end
    end
  end
end

class PrintUsersLinksAction < SafeAction
  def self.args
    [:message, /^!links( .+)?$/]
  end

  def self._action(m, nick_name)
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
    end
  end
end
