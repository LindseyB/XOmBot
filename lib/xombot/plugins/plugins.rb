class Plugins < XOmBot::Plugin
  match "plugins"

  def execute(m)
    m.reply "Plugins:"
    XOmBot::plugins.keys.each do |p|
      m.reply "-- #{p}"
    end
  end
end
