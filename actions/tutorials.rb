require_relative './base'

class TutorialCreateAction < BaseAction
  help_description do
    '!tutorial (description of tutorial) : suggest a potential tutorial for techendo'
  end

  args do
    [:message, /^!tutorial (.+)$/]
  end

  action do |m, message|
    unless Tutorial.create(:description => message, :author => m.user.nick)
      m.reply "Sorry, that didn't work. There must be something wrong with me today."
    else
      m.reply "Recorded tutorial: #{message}, by author: #{m.user.nick} at #{Time.now}"
    end
  end
end

class TutorialListAction < BaseAction
  help_description do
    '!tutorials (--spam) : I will whisper the list of tutorials to you. Use --spam to spam the channel instead'
  end

  args do
    [:message, /^\!tutorials( --spam)?$/]
  end

  action do |m, spam_channel|
    Tutorial.find(:all).each do |t|
      message = "#{t.id} : #{t.description} (submitted by #{t.author})"

      if spam_channel
        m.reply message
      else
        m.user.send message
      end
    end
  end
end

class TutorialDeleteAction < BaseAction
  help_description do
    '!delete tutorial (id) : delete a tutorial'
  end

  args do
    [:message, /^!delete tutorial (\d+)$/]
  end

  action do |m, id|
    tut = Tutorial.find(id)
    if tut.author == m.user.nick || m.user.nick == "dpg"
      Tutorial.destroy(id)
      m.reply "Successfully destroyed tutorial: #{tut.id}, by #{tut.author}"
    end
  end
end
