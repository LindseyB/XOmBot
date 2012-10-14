class Tweet < XOmBot::Plugin
  match /tweet (\d+)/, :method => :tweet_by_id
  help "Displays the tweet with the given id"
  usage "tweet 12345678 -- displays the twitter update with that id"
  
  match /tweet (\w.*)/, :method => :tweet_by_username
  help "Displays the latest tweet by the given user"
  usage "tweet noob -- displays the last tweet by noob"

  def setup
    url_plugin = XOmBot.plugins["URLAnnounce"]
    if url_plugin
      url_plugin.match_domain("twitter.com") do |m, url|
        tweet_by_url m, url
      end
    end
  end

  def tweet_by_id(m, id)
    status = Twitter.status(id)
    m.reply "@#{status.user.screen_name}: #{HTMLEntities.new.decode status.text}"
  end

  def tweet_by_username(m, username)
    m.reply "@#{username}: #{HTMLEntities.new.decode Twitter.user_timeline(username).first.text}" 
  end

  def tweet_by_url(m, url)
    id = url[/^https?:\/\/.*\/status\/(\d+)/,1]
    tweet_by_id m, id
  end
end
