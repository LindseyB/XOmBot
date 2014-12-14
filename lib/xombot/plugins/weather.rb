class Weather < XOmBot::Plugin
  WEATHER_QUERY_URL = "http://www.wunderground.com/cgi-bin/findweather/hdfForecast?query="

  match /weather ([^ ]+)(?:\s(.+))?/
  help "gives the forecast for the given city"
  usage "weather pittsburgh -- gives the weather for pittsburgh"
  usage "weather melbourne, australia -- gives the weather for melbourne australia"

  def execute(m, place, place2)
    @agent = Mechanize.new
    page = @agent.get "#{WEATHER_QUERY_URL}#{place}#{place2}"

    # unfortunately their 404 page returns 200 :(
    if page.at('body').text.include? "Error 404: Page Not Found"
      m.reply "Unable to weather for #{place}, are you sure it exists?"
    elsif page.at('body').attr('class').include? "not-set"
      m.reply "Ambiguous location, can you be more specific?"
    else
      current_weather = page.search 'span[data-variable="temperature"] .wx-value'
      current_phrase  = page.search 'div[data-variable="condition"] .wx-value'

      temp = current_weather.text.to_i
      temp_cel = (temp - 32) * 5 / 9
      m.reply "Weather in #{place}: #{temp}\u00b0F/#{temp_cel}\u00b0C and #{current_phrase.text}"
    end
  end
end
