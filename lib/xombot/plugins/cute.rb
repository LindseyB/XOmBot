class Cute < XOmBot::Plugin
  CUTE_IDS     = %w[aww corgi kitty   puppy   capybara]
  CUTE_SOURCES = %w[aww corgi kittens puppies capybara]

  def initialize *args
    @agent  = Mechanize.new { |agent|
      agent.request_headers = {"Authorization" => "Client-ID #{XOmBot.imgur_client_id}"}
    }
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
    begin
      return @cuties[type].pop unless @cuties[type].empty?

      subreddit = type
      sitename  = "https://api.imgur.com/3/gallery/r/#{subreddit}.json"
      content   = JSON.parse(@agent.get(sitename).body)

      content["data"].each do |data|
        @cuties[type] << "http://imgur.com/#{data["id"]} - #{data["title"]}"
      end

      @cuties[type].pop

    rescue Mechanize::Error => e
      "no braaaaaaaiiiiiins #{e}"
    end
  end
end
