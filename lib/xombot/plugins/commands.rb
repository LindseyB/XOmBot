class Commands < XOmBot::Plugin
  match "commands"
  help "Will list all of the available commands"

  def execute(m)
    XOmBot.plugins.each do |p|
      p.commands.each do |k,v|
        m.reply "!#{k} -- #{v}"
      end
    end
  end
end
