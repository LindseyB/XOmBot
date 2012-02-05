require 'bundler'
Bundler.require

require 'xombot/plugins/hello'

module XOmBot
  class << self
    def load_plugins
    end

    def start
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
    end
  end
end
