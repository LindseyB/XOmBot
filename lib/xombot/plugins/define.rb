class Define < XOmBot::Plugin
  DICTIONARY_QUERY_URL = "http://dictionary.reference.com/browse/"

  match /define (.+)/
  help "retrieves the definition for the given english word"
  usage "define bier -- prints the definition of the word bier"

  def execute(m, word)
    @agent = Mechanize.new
    page = @agent.get "#{DICTIONARY_QUERY_URL}#{word}"
    part_of_speech = page.search('//div[@class="pbk"]/span[@class="pg"]').first.content.strip
    definition = []
    definitions = page.search('//div[@class="pbk"]/div[@class="luna-Ent"]')
    definition << definitions.first.children.inject("") do |result, element|
      result + element.content
    end
    definition[0].gsub! /^\d+\./, ""

    if (definitions.count > 1)
      definition << definitions[1].children.inject("") do |result, element|
        result + element.content
      end
      definition[1].gsub! /^\d+\./, ""
    end

    m.reply "#{word}: (#{part_of_speech})"
    m.reply "#{" "*(word.length-1)}1. #{definition[0]}"
    if definition[1]
      m.reply "#{" "*(word.length-1)}2. #{definition[1]}#{definitions.count-3 > 0 ? " (#{definitions.count-3} definitions follow...)" : ""}"
    end
  end
end
