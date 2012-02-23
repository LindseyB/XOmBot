class Seen < XOmBot::Plugin
  # This plugin is based on a Cinch example
  class SeenStruct < Struct.new(:who, :where, :what, :time)
    def to_s(current_channel = nil)
      ret = "[#{time.asctime}] #{who} was seen"
      if current_channel != where
        ret << " in #{where}"
      end
      ret << " saying #{what}"
    end
  end

  listen_to :channel

  def initialize(*args)
    @users = {}
    super *args
  end

  def listen(m)
    @users[m.user.nick] = SeenStruct.new m.user, m.channel, m.message, Time.now
  end

  match /seen (.+)/
  help "Reports the last moment a given person spoke"
  usage "seen wilkie -- Reports the last moment wilkie spoke"

  def execute(m, nick)
    if nick == @bot.nick
      m.reply "I'm looking for brains."
    elsif nick == m.user.nick
      m.reply "Can I eat your brains? You aren't using them."
    elsif @users.key? nick
      m.reply @users[nick].to_s(m.channel)
    else
      m.reply "I have not seen #{nick}. Rar."
    end
  end
end
