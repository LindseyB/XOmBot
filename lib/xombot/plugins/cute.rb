class Cute < XOmBot::Plugin
  CUTE_IDS     = %w[aww corgi kitty   puppy]
  CUTE_SOURCES = %w[aww corgi kittens puppies]

  def initialize *args
    @agent  = Mechanize.new
    @cuties = {}
    CUTE_SOURCES.each do |source|
      @cuties[source] = []
    end

    super *args
  end

  CUTE_IDS.zip(CUTE_SOURCES).each do |id, source|
    match id, :method => "get_#{id}".to_sym
    if id == "aww"
      help "find a cute picture from the internet"
    else
      help "find a cute #{id} from the internet"
    end

    define_method "get_#{id}".to_sym do |m|
      m.reply get_cuteness(source)
    end
  end

  def get_cuteness(type)
    return @cuties[type].pop unless @cuties[type].empty?

    subreddit = type
    sitename  = "http://imgur.com/r/#{subreddit}.json"
    content   = JSON.parse(@agent.get(sitename).body)

    content["data"].each do |data|
      @cuties[type] << "http://imgur.com/#{data["hash"]} - #{data["title"]}"
    end

    @cuties[type].pop
  end
end
