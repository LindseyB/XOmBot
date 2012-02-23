class Joke < XOmBot::Plugin
  JOKE_DOMAIN = "http://www.abdn.ac.uk/jokingcomputer/webversion"
  JOKE_ACTIONS = {
    :start => "startFUN.php",
    :new   => "getjokeFUN.php?class=any&subject=any",
    :joke  => "fulldisplay.php" }

  def initialize *args
    @agent = Mechanize.new
    @joke = {}
    @answer = {}

    super *args
  end

  match "joke", :method => :tell_joke
  help "Tells a funny joke"

  match "answer", :method => :tell_answer
  help "Gives you the answer"

  def tell_joke(m)
    @agent.get "#{JOKE_DOMAIN}/#{JOKE_ACTIONS[:start]}"
    @agent.get "#{JOKE_DOMAIN}/#{JOKE_ACTIONS[:new]}"
    page = @agent.get "#{JOKE_DOMAIN}/#{JOKE_ACTIONS[:joke]}"

    joke_div = page.search '//div[@class="jokermediumtext"]'
    @joke[m.channel] = nil
    @answer[m.channel] = nil

    # The joke and answer are separated by <br/>, so just 
    # enumerate the text of the div.
    joke_div.first.children.each do |c|
      if c.text?
        if @joke[m.channel].nil?
          @joke[m.channel] = c.content
        else
          @answer[m.channel] = c.content.chop
        end
      end
    end

    m.reply @joke[m.channel]
  end

  def tell_answer(m)
    m.reply "#{@answer[m.channel]}! Oh ho ho ho... brains."
  end
end
