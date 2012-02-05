require 'bundler'
Bundler.require

require 'xombot/plugin'

# Place all plugins into a module
Dir[File.dirname(__FILE__) + '/xombot/plugins/*.rb'].each do |file|
  eval "module XOmBot; module Plugins; #{File.read(file)}; end; end"
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
#          c.plugins.plugins = [
#            XOmBot::Plugins::Hello,
#            XOmBot::Plugins::Commands,
#            XOmBot::Plugins::Joke,
#            XOmBot::Plugins::Plugins
#          ]
          c.plugins.plugins = XOmBot::Plugins.constants.map do |plugin|
            XOmBot::Plugins.const_get(plugin)
          end
        end
      end

      bot.start
    end
  end
end
