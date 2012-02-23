require 'xombot'
require 'optparse'

module XOmBot
  class CLI
    BANNER = <<-USAGE
    Usage:
    Run with the default parameters:
      xombot
    USAGE

    class << self
      def parse_options
        @opts = OptionParser.new do |opts|
          opts.banner = BANNER.gsub(/^\s{4}/, '')

          opts.separator ''
          opts.separator 'Options:'

          opts.on('-h', '--help', 'Display this help') do
            puts opts
            exit
          end
        end

        @opts.parse!
      end

      def run
        XOmBot.start
      end
    end
  end
end
