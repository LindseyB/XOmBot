class Coinflip < XOmBot::Plugin
  match /coinflip(?: (.+) or (.+))?/
  help "Flips a coin"
  usage "coinflip -- Returns either heads or tails"
  usage "coinflip x or y -- Returns either x or y"

  def execute(m, heads = nil, tails = nil)
    result = rand(2)
    if result == 0
      if heads
        m.reply heads
      else
        m.reply "heads"
      end
    else
      if tails
        m.reply tails
      else
        m.reply "tails"
      end
    end
  end
end
