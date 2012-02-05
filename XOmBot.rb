require 'bundler'
Bundler.require

class Hello
  include Cinch::Plugin

  match "hello"

  def execute(m)
    bot.logger.debug "Someone said hello"
    m.reply "Hello, #{m.user.nick}"
  end
end

bot = Cinch::Bot.new do
  configure do |c|
    c.server = "irc.freenode.org"
    c.port = 6697
    c.ssl.use = true
    c.nick = "XOmBot-test"
    c.channels = ["#XOmBot"]
    c.plugins.plugins = [Hello]
  end
end

bot.start
