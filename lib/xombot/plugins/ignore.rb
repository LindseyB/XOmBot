class Ignore < XOmBot::Plugin
  match /ignore (.+)/, :method => :ignore
  help "Ignores speech from a particular user"
  usage "ignore wilkie -- XOmBot will not respond to wilkie"

  match /unignore (.+)/, :method => :unignore
  help "Reverses decision to ignore speech from a particular user"
  usage "unignore wilkie -- XOmBot will now respond to wilkie"

  attr_reader :ignored

  def initialize(*args)
    super(*args)

    @ignored = []
  end

  def ignore(m, nick)
    @ignored << nick
    m.emote "ignores #{nick}'s brains."
  end

  def unignore(m, nick)
    @ignored.delete nick
    m.emote "again finds #{nick}'s brains delicious."
  end
end
