class Google < XOmBot::Plugin
  match /google (.+) for (.+?)( dammit)?$/
  help "Links given nick to a google search"
  usage "google llamas for cl0ckw0rk -- Gives cl0ckwork a useful search link"
  usage "google garlic toast for wolfwood dammit -- Ditto, but with more luck"
  
  def execute(m, query, nick, for_real)
    m.reply "#{nick}: http://lmgtfy.com/?q=#{query}#{for_real ? "&l=1" : ""}"
  end
end
