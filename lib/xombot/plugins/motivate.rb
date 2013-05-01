class Motivate < XOmBot::Plugin
  match /m (\S+)/, :method => :motivate
  match /h5 (\S+)/, :method => :high_five
  help "Displays a little motivational love."
  usage ["m name -- displays You're doing good work, name!",
         "h5 name -- emotes a high five to name"].join("\n")

  def motivate(m, name)
    m.reply "You're doing good work, #{name}!"
  end
  
  def high_five(m, name)
    m.emote "high fives #{name}!"
  end
end
