class Commands < XOmBot::Plugin
  match "commands"
  help "Will list all of the available commands"

  def execute(m)
    commands = []
    XOmBot.plugins.each do |_,p|
      p.commands.each do |k,v|
        short_name = k.inspect.to_s[1..-2][/\w+/]
        commands << short_name unless commands.include?(short_name)
        if v[:help]
        #  m.reply "!#{} -- #{v[:help]}"
        end
      end
    end

    m.reply "Commands: #{commands.sort.join(", ")}"
  end
end
