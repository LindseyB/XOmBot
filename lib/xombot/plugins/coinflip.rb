class Coinflip < XOmBot::Plugin
  match "coinflip"
  help "Flips a coin"

  def execute(m)
    result = rand(2)
    if result == 0
      m.reply "heads"
    else
      m.reply "tails"
    end
  end
end
