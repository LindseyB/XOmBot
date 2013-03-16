require 'open-uri'

class Rstatus < XOmBot::Plugin
  match /rstatus (\w+)/, :method => :rstatus_by_id
  help "Displays the rstatus update with the given id"
  usage "rstatus 12345678 -- displays the rstatus update with that id"
  

  def setup
    url_plugin = XOmBot.plugins["URLAnnounce"]
    if url_plugin
      url_plugin.match_domain("rstat.us") do |m, url|
        rstatus_by_url m, url
      end
    end
  end

  def rstatus_by_id(m, id)
    rstatus_by_url m, "https://rstat.us/updates/#{id}"
  end


  def rstatus_by_url(m, url)
    doc = Nokogiri::HTML(open(url))
    m.reply "@#{doc.css('.byline a:nth-child(2)').first.text.strip!}: #{doc.css('.content').first.text.strip!}"
  end
end
