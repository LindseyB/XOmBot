class Dice < XOmBot::Plugin
  match /d(\d+)/, :method => :roll_single
  help "Rolls a single die of the given number of sides"
  usage "d2 -- Flips a coin"
  usage "d6 -- Rolls a traditional 6 sided die"

  def roll_single(m, dice_amount)
    dice_amount = dice_amount.to_i
    if dice_amount == 0
      m.reply "Infinite brains..."
    else
      m.reply rand(dice_amount) + 1
    end
  end

  # Following is based on a Cinch plugin
  match /roll (?:(?:(\d+)#)?(\d+))?d(\d+)(?:([+-])(\d+))?/, :method => :roll
  help "Rolls a set of dice with an optional offset"
  usage "roll d6 -- Rolls a single, 6-sided die"
  usage "roll 3d6-1 -- Sums the rolls of 3 6-sided dice with a -1 offset"

  def roll(m, repeats, rolls, sides, offset_op, offset)
    repeats = repeats.to_i
    repeats = 1 if repeats < 1
    rolls = rolls.to_i
    rolls = 1 if rolls < 1

    total = 0

    repeats.times do
      rolls.times do
        score = rand(sides.to_i) + 1
        if offset_op
          score = score.send(offset_op, offset.to_i)
        end
        total += score
      end
    end

    m.reply "dice roll was: #{total}", true
  end
end
