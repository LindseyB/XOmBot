class Joke < XOmBot::Plugin
  JOKE_DOMAIN = "http://www.abdn.ac.uk/jokingcomputer/webversion"
  JOKE_ACTIONS = {
    :start => "startFUN.php",
    :new   => "getjokeFUN.php?class=any&subject=any",
    :joke  => "fulldisplay.php" }

  def initialize *args
    @agent = Mechanize.new

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
    @joke = nil
    @answer = nil

    # The joke and answer are separated by <br/>, so just 
    # enumerate the text of the div.
    joke_div.first.children.each do |c|
      if c.text?
        if @joke.nil?
          @joke = c.content
        else
          @answer = c.content
        end
      end
    end

    m.reply @joke
  end

  def tell_answer(m)
    m.reply @answer
  end
end
