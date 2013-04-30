class Motivate < XOmBot::Plugin
  match /m (\S+)/, :method => :motivate
  help "Displays a little motivational love."
  usage "m name -- displays You're doing good work, name!"

  def motivate(m, name)
    m.reply "You're doing good work, #{name}!"
  end
end
