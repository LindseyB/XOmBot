class URLAnnounce < XOmBot::Plugin
  listen_to :channel

  def listen(m)
    m.message.scan /https?:\/\/[\S]+/ do |url|
      page = Mechanize.new.get url
      m.reply "Title: #{page.title}"
    end
  end
end
