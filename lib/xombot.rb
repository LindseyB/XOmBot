require 'bundler'
Bundler.require

# allow sending of actions
module Cinch
  class Message
    def emote(m)
      reply "\001ACTION #{m}\001"
    end
  end
end

require 'xombot/plugin'

# Place all plugins into a module
Dir[File.dirname(__FILE__) + '/xombot/plugins/*.rb'].each do |file|
  eval "module XOmBot; module Plugins; #{File.read(file)}; end; end"
end

module XOmBot
  NAME = "XOmBot-test"

  class << self
    attr_reader :plugins

    def add_plugin plugin
      @plugins = [] if @plugins.nil?
      @plugins << plugin
    end

    def load_plugins
    end

    def name
      NAME
    end

    def start
      bot = Cinch::Bot.new do
        configure do |c|
          c.server = "irc.freenode.org"
          c.port = 6697
          c.ssl.use = true
          c.nick = NAME 
          c.channels = ["#XOmBot"]
          c.plugins.plugins = XOmBot::Plugins.constants.map do |plugin|
            XOmBot::Plugins.const_get(plugin)
          end
        end
      end

      bot.start
    end
  end
end
