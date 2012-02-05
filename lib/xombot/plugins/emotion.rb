class Emotion < XOmBot::Plugin
  listen_to :channel

  def initialize *args
    super *args

    @good = 0
    @bad = 0
  end

  def listen(m)
    return unless m.message.match XOmBot.name

    if m.message.match /good|cookie|<3/
      @good = @good + 1
      m.emote "drools"
      return
    end

    if m.message.match /bad|spank/
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
