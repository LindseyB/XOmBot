class Plugins < XOmBot::Plugin
  match "plugins"

  def execute(m)
    m.reply "Plugins:"
    XOmBot::plugins.each do |p|
      m.reply "-- #{p.class.name}"
    end
  end
end
