module XOmBot
  class Plugin
    include Cinch::Plugin

    def initialize *args
      # Register the plugin with XOmBot
      XOmBot.add_plugin self
      super *args
    end

    module ModuleSet
      attr_reader :matches

      def match m, *args
        @last_match = m
        super m, *args      
      end

      def help m, *args
        @matches = {} unless @matches
        @matches[@last_match] = {} unless @matches[@last_match]
        @matches[@last_match][:help] = m
      end

      def usage m, *args
        @matches = {} unless @matches
        @matches[@last_match] = {} unless @matches[@last_match]
        @matches[@last_match][:usage] = [] unless @matches[@last_match][:usage]
        @matches[@last_match][:usage] << m
      end
    end

    extend ModuleSet

    def commands
      self.class.matches || {}
    end
  end
end
