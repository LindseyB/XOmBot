class URLAnnounce < XOmBot::Plugin
  listen_to :channel

  def listen(m)
    ignore_plugin = XOmBot.plugins["XOmBot::Plugins::Ignore"]
    return if ignore_plugin and ignore_plugin.ignored.include? m.user.nick

    m.message.scan /https?:\/\/[\S]+/ do |url|
      page = Mechanize.new.get url
      if page.is_a? Mechanize::Page
        m.reply "Title: #{page.title.gsub(/\t|\r|\n/, " ").strip}"
      end
    end
  end
end
