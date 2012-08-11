require 'uri'

class LocalTime < XOmBot::Plugin
  TIME_QUERY_URL = "http://www.timeanddate.com/worldclock/results.html?query="

  match /time (.+)/
  help "gives the local time in the given city"
  usage "time Melbourne -- gives the time in Melbourne Australia"

  def execute(m, place)
    @agent = Mechanize.new
    page = @agent.get "#{TIME_QUERY_URL}#{URI.escape(place)}"
    current_time = page.search '//strong[@id="ct"]'

    m.reply "Time in #{place}: #{current_time.first.content}"
  end
end
