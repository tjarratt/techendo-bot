class Link < ActiveRecord::Base
  def self.create(args)
    if args[:author].match(/techendo\-pal/)
      return false
    end
  end
end
