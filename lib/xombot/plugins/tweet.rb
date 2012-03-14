class Tweet < XOmBot::Plugin
  match /tweet (\d+)/
  help "Displays the tweet with the given id"
  usage "tweet 12345678 -- displays the twitter update with that id"

  def execute(m, id)
    status = Twitter.status(id)
    m.reply "@#{status.user.screen_name}: #{status.text}"
  end
end
