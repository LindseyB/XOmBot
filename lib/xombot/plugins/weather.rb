class Weather < XOmBot::Plugin
  WEATHER_QUERY_URL = "http://weather.com/search/enhancedlocalsearch?where="

  match /weather ([^ ]+)(?:\s(.+))?/
  help "gives the forecast for the given city"
  usage "weather pittsburgh -- gives the weather for pittsburgh"
  usage "weather melbourne hourly -- gives a 6 hour forecase for melbourne"

  def execute(m, place, option)
    @agent = Mechanize.new
    page = @agent.get "#{WEATHER_QUERY_URL}#{place}"
    current_weather = page.search '//span[@itemprop="temperature-fahrenheit"]'
    current_phrase  = page.search '//span[@itemprop="weather-phrase"]'

    if option == "hourly"
      hourly_url = page.search '//a[@from="rightnow_1"]'
      if hourly_url.first.nil?
        hourly_url = page.search '//a[@from="rightnow_TimeNav_weather_nav"][@title="Hourly"]'
      end

      if hourly_url.first.nil?
        m.reply "No hourly forecast available."
        return
      end

      hourly_url = hourly_url.first.attribute "href"
      page = @agent.get "http://weather.com#{hourly_url}"

      parts = page.search('//div[@class="wx-timepart"]').to_a
      parts.insert(0, page.search('//div[@class="wx-timepart wx-first"]'))

      reply_string = parts.inject("") do |a, part|
        hour = part.children[1].children[0].content.to_i
        meridian = part.children[1].children[1].content.strip
        if meridian.upcase == "PM"
          hour += 12
        end
        temp = part.children[3].children[2].content.strip.to_i
        phrase = part.children[3].children[4].content
        temp_cel = (temp - 32) * 5 / 9
        "#{a} #{hour}:00: #{temp}\u00b0F/#{temp_cel}\u00b0C/#{phrase}"
      end
      m.reply "#{place} by hour:#{reply_string}"
    else
      temp = current_weather.first.content.to_i
      temp_cel = (temp - 32) * 5 / 9
      m.reply "Weather in #{place}: #{temp}\u00b0F/#{temp_cel}\u00b0C and #{current_phrase.first.content}"
    end
  end
end
