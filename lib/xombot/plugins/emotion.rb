class Emotion < XOmBot::Plugin
  listen_to :channel

  def initialize *args
    super *args

    @good = 0
    @bad = 0
  end

  def listen(m)
    # Sometimes XOmBot overhears things intended for others
    unless m.message.match /#{XOmBot.name}/i
      return
    end

    # XOmBot does not appreciate being looked down upon
    if m.message.match /\bfuck you\b/
      m.reply m.message.gsub(/#{XOmBot.name}/i, m.user.nick).gsub(/fuck you/i, "fuck you too")
      return
    end

    # XOmBot responds well to appreciation
    if m.message.match /good|cookie|hugs|cake|nice|awesome|pets|kiss|<3/
      @good = @good + 1
      m.emote "drools"
      return
    end

    # XOmBot responds to negative remarks
    if m.message.match /bad|spank|spit|shoot|slap|\:\(/
      @bad = @bad + 1
      m.emote "cowers"
      return
    end

    m.emote "brains..."
  end

  match "santa"

  def execute(m)
    if @good >= @bad
      m.emote "has been a good little robotic zombie"
    else
      m.emote "is getting coal in its metal stocking"
    end
  end
end
