class Hello
  include Cinch::Plugin

  match "hello"
  help "This command says hello."

  def execute(m)
    m.reply "Hello, #{m.user.nick}"
  end
end
