class Tweet < XOmBot::Plugin
  match /tweet (\d+)/, :method => :tweet_by_id
  help "Displays the tweet with the given id"
  usage "tweet 12345678 -- displays the twitter update with that id"
  
  match /tweet (\w.*)/, :method => :tweet_by_username
  help "Displays the latest tweet by the given user"
  usage "tweet noob -- displays the last tweet by noob"

  def tweet_by_id(m, id)
    status = Twitter.status(id)
    m.reply "@#{status.user.screen_name}: #{status.text}"
  end

  def tweet_by_username(m, username)
   m.reply "@#{username}: #{Twitter.user_timeline(username).first.text}" 
  end
end
