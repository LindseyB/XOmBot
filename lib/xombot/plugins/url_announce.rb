class URLAnnounce < XOmBot::Plugin
  listen_to :channel

  def listen(m)
    ignore_plugin = XOmBot.plugins["Ignore"]
    return if ignore_plugin and ignore_plugin.ignored.include? m.user.nick

    m.message.scan /https?:\/\/[\S]+/ do |url|
      dispatch m, url
    end
  end

  def dispatch(m, url)
    domain = url[/https?:\/\/(?:[^.]+\.)?([^.]+\.[^\/]+)(?:\/|$)/, 1]

    @callback = @callback || {}
    if @callback[domain]
      @callback[domain].call m, url
    else
      default_announce m, url
    end
  end

  def match_domain(domain, &block)
    @callback = @callback || {}
    @callback[domain] = block
  end

  def default_announce(m, url)
    begin
      page = Mechanize.new.get url

      if page.is_a? Mechanize::Page
        m.reply "Title: #{page.title.gsub(/\t|\r|\n/, " ").strip}"
      end
    rescue
    end
  end
end
