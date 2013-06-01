require 'open-uri'

class Tweet < XOmBot::Plugin
  match /tweet (\d+)/, :method => :tweet_by_id
  help "Displays the tweet with the given id"
  usage "tweet 12345678 -- displays the twitter update with that id"

  match /tweet (\w.*)/, :method => :tweet_by_username
  help "Displays the latest tweet by the given user"
  usage "tweet noob -- displays the last tweet by noob"

  def setup
    url_plugin = XOmBot.plugins["URLAnnounce"]
    if url_plugin
      url_plugin.match_domain("twitter.com") do |m, url|
        tweet_by_url m, url
      end
    end
  end

  def tweet_by_id(m, id)
    tweet_by_url m, "https://twitter.com/a/status/#{id}"
  end

  def tweet_by_username(m, username)
    doc = Nokogiri::HTML(open("https://twitter.com/#{username}"))
    # terrible selector to grab the first tweet that isn't a reply or retweeted
    tweet = doc.xpath("//*[contains(concat(' ', @class, ' '), ' original-tweet ') and not(@data-is-reply-to = \"true\") and not(@data-retweet-id)]")
               .first
    tweet ? tweet_by_id(m, tweet.attr('data-tweet-id')) : m.reply("#{username} doesn't have any recent tweets")
  end

  def tweet_by_url(m, url)
    doc = Nokogiri::HTML(open(url))
    m.reply "#{doc.css('.permalink-tweet-container .username.js-action-profile-name').first.text}: #{doc.css('.permalink-tweet-container .tweet-text').first.text}"
  end
end
