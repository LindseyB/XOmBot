require 'bundler'
Bundler.require

# Place all plugins into a module
module XOmBot
  module Plugins
    require 'xombot/plugins/hello'
    require 'xombot/plugins/commands'
    require 'xombot/plugins/plugins'

    def self.const_missing(c)
      Object.const_get(c)
    end
  end
end

module XOmBot
  class << self
    attr_reader :plugins

    def add_plugin plugin
      @plugins = [] if @plugins.nil?
      @plugins << plugin
    end

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
          c.plugins.plugins = [
            XOmBot::Plugins::Hello,
            XOmBot::Plugins::Commands,
            XOmBot::Plugins::Plugins
          ]
        end
      end

      bot.start
    end
  end
end
